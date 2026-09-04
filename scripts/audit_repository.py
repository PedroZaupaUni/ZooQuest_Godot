#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
ERRORS: list[str] = []
CHECKS = 0


def check(condition: bool, message: str) -> None:
    global CHECKS
    CHECKS += 1
    if not condition:
        ERRORS.append(message)


def tracked_files() -> list[Path]:
    proc = subprocess.run(
        ["git", "ls-files", "-z"], cwd=ROOT, check=True, stdout=subprocess.PIPE
    )
    return [ROOT / p.decode("utf-8") for p in proc.stdout.split(b"\0") if p]


files = tracked_files()
rel = [p.relative_to(ROOT).as_posix() for p in files]

# Arquivos locais/gerados que nao devem entrar no historico.
for path in rel:
    check(not path.startswith(".godot/"), f"arquivo gerado rastreado: {path}")
    check(not re.match(r"^validation/FIX1_[^/]+/", path), f"log local FIX1 rastreado: {path}")
    check(not re.match(r"^validation/GOVERNANCE_[^/]+/", path), f"log local governance rastreado: {path}")
    check(not path.endswith((".log", ".tmp", ".swp")), f"temporario/log rastreado: {path}")
    check(not path.endswith(".patch"), f"patch operacional nao deve ser rastreado: {path}")

# Evita arquivos grandes acidentais no projeto academico.
MAX_BYTES = 25 * 1024 * 1024
for p in files:
    if p.exists() and p.is_file():
        check(p.stat().st_size <= MAX_BYTES, f"arquivo >25 MiB: {p.relative_to(ROOT)}")

required = [
    "project.godot",
    "core/main.gd",
    "data/questions.json",
    "data/story_flow.json",
    "scripts/validate_repository.py",
    "scripts/validate_runtime_patterns.py",
    "scripts/audit_repository.py",
    "scripts/check_godot_logs.sh",
    "tests/smoke_test.gd",
    "tests/smoke_test.tscn",
    "tests/flow_transition_test.gd",
    "tests/flow_transition_test.tscn",
    ".github/workflows/ci.yml",
    ".github/pull_request_template.md",
    ".github/CODEOWNERS",
    ".github/rulesets/main-protection.json",
]
for item in required:
    check((ROOT / item).is_file(), f"arquivo obrigatorio ausente: {item}")

# JSONs canonicos devem ser validos.
for item in ("data/questions.json", "data/story_flow.json"):
    try:
        json.loads((ROOT / item).read_text(encoding="utf-8"))
        check(True, f"JSON valido: {item}")
    except Exception as exc:  # pragma: no cover
        check(False, f"JSON invalido {item}: {exc}")

project_text = (ROOT / "project.godot").read_text(encoding="utf-8", errors="replace")
check('run/main_scene="res://core/main.tscn"' in project_text, "project.godot sem main scene canonica")
for autoload in ("GameState", "QuestionBank", "FlowRepository", "AudioManager"):
    check(f'{autoload}="*res://' in project_text, f"autoload ausente: {autoload}")

workflow = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
check("pull_request_target" not in workflow, "workflow usa pull_request_target")
check(re.search(r"(?m)^permissions:\s*$", workflow) is not None, "workflow sem bloco permissions")
check(re.search(r"(?m)^\s{2}contents:\s*read\s*$", workflow) is not None, "GITHUB_TOKEN nao esta contents: read")
check("smoke_test.tscn" in workflow, "CI nao executa smoke em cena de runtime")
check("flow_transition_test.tscn" in workflow, "CI nao executa flow em cena de runtime")
check("check_godot_logs.sh" in workflow, "CI nao audita logs Godot")

# Actions externas devem estar fixadas em SHA completo.
for m in re.finditer(r"(?m)^\s*-?\s*uses:\s*([^@\s]+)@([^\s#]+)", workflow):
    action, ref = m.groups()
    if action.startswith("./"):
        continue
    check(bool(re.fullmatch(r"[0-9a-fA-F]{40}", ref)), f"Action nao pinada em SHA: {action}@{ref}")

# Marcadores de conflito em arquivos-fonte/configuracao.
text_suffixes = {".gd", ".tscn", ".tres", ".json", ".yml", ".yaml", ".md", ".cfg", ".godot", ".py", ".sh"}
for p in files:
    if p.suffix.lower() not in text_suffixes and p.name != "project.godot":
        continue
    try:
        text = p.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    bad = bool(re.search(r"(?m)^<<<<<<< |^>>>>>>> |^=======$", text))
    check(not bad, f"marcador de conflito Git: {p.relative_to(ROOT)}")

print("ZOOQUEST_REPOSITORY_AUDIT=" + ("PASS" if not ERRORS else "FAIL"))
print(f"CHECKS_TOTAL={CHECKS}")
print(f"ERRORS={len(ERRORS)}")
for error in ERRORS:
    print(f"ERROR {error}")
sys.exit(1 if ERRORS else 0)
