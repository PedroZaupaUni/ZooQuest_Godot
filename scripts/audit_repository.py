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

for path in rel:
    check(not path.startswith(".godot/"), f"arquivo gerado rastreado: {path}")
    check(not re.match(r"^validation/FIX1_[^/]+/", path), f"log local FIX1 rastreado: {path}")
    check(not re.match(r"^validation/GOVERNANCE_[^/]+/", path), f"log local governance rastreado: {path}")
    check(not path.endswith((".log", ".tmp", ".swp", ".pyc")), f"temporario/log/cache rastreado: {path}")
    check("/__pycache__/" not in ("/" + path), f"__pycache__ rastreado: {path}")
    check(not path.endswith(".patch"), f"patch operacional nao deve ser rastreado: {path}")

MAX_BYTES = 25 * 1024 * 1024
for p in files:
    if p.exists() and p.is_file():
        check(p.stat().st_size <= MAX_BYTES, f"arquivo >25 MiB: {p.relative_to(ROOT)}")

required = [
    "project.godot",
    "core/main.gd",
    "core/audio_manager.gd",
    "data/questions.json",
    "data/story_flow.json",
    "scripts/validate_repository.py",
    "scripts/validate_runtime_patterns.py",
    "scripts/audit_repository.py",
    "scripts/check_godot_logs.sh",
    "scripts/run_godot_smoke.sh",
    "scripts/update_repository_metadata.py",
    "tests/smoke_test.gd",
    "tests/smoke_test.tscn",
    "tests/flow_transition_test.gd",
    "tests/flow_transition_test.tscn",
    "tests/main_startup_test.gd",
    "tests/main_startup_test.tscn",
    ".github/workflows/ci.yml",
    ".github/pull_request_template.md",
    ".github/CODEOWNERS",
    ".github/rulesets/main-protection.json",
    ".github/rulesets/develop-protection.json",
    "scripts/validate_branch_policy.sh",
]
for item in required:
    check((ROOT / item).is_file(), f"arquivo obrigatorio ausente: {item}")

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
check("main_startup_test.tscn" in workflow, "CI nao executa startup limpo da Main")
check("check_godot_logs.sh" in workflow, "CI nao audita logs Godot")
check("--verbose" in workflow, "CI Godot sem --verbose para diagnostico de leaks")
check("GODOT_SHA256" in workflow, "CI nao fixa SHA-256 do binario Godot")
check("sha256sum -c" in workflow, "CI nao verifica SHA-256 do binario Godot")
check("Godot_v4.7.2-stable_linux.x86_64.zip" in workflow, "CI nao fixa artefato Godot 4.7.2")
old_main_kill = 'timeout 8s "$GODOT" --headless --path . --log-file godot-main.log'
check(old_main_kill not in workflow, "CI ainda mata a Main por timeout em vez de teardown limpo")

# Git flow governance contracts.
check(workflow.count("branches: [main, develop]") >= 2, "CI nao cobre pull_request/push de main e develop")
check("branch-policy" in workflow, "CI sem job branch-policy")
check("validate_branch_policy.sh" in workflow, "CI nao executa politica de branches")
branch_policy = (ROOT / "scripts/validate_branch_policy.sh").read_text(encoding="utf-8")
check("HEAD_REF" in branch_policy and "BASE_REF" in branch_policy, "branch-policy sem refs de PR")
check("base=main" in branch_policy and "expected=develop" in branch_policy, "branch-policy sem regra main <- develop")
check("base=develop" in branch_policy and "feature|fix|chore|docs|test|hotfix" in branch_policy, "branch-policy sem regra branches -> develop")

for ruleset_path, expected_ref, expected_method, expected_strict in (
    (".github/rulesets/main-protection.json", "~DEFAULT_BRANCH", "merge", False),
    (".github/rulesets/develop-protection.json", "refs/heads/develop", "squash", True),
):
    try:
        ruleset = json.loads((ROOT / ruleset_path).read_text(encoding="utf-8"))
        includes = ruleset.get("conditions", {}).get("ref_name", {}).get("include", [])
        check(expected_ref in includes, f"ruleset {ruleset_path} nao protege {expected_ref}")
        contexts = []
        pull_methods = []
        strict_value = None
        for rule in ruleset.get("rules", []):
            if rule.get("type") == "required_status_checks":
                params = rule.get("parameters", {})
                contexts = [item.get("context") for item in params.get("required_status_checks", [])]
                strict_value = params.get("strict_required_status_checks_policy")
            if rule.get("type") == "pull_request":
                pull_methods = rule.get("parameters", {}).get("allowed_merge_methods", [])
        for context in ("branch-policy", "repository-audit", "godot-tests"):
            check(context in contexts, f"ruleset {ruleset_path} sem check {context}")
        check(expected_method in pull_methods and len(pull_methods) == 1, f"ruleset {ruleset_path} metodo de merge incorreto")
        check(strict_value is expected_strict, f"ruleset {ruleset_path} strict policy incorreta")
    except Exception as exc:
        check(False, f"ruleset invalido {ruleset_path}: {exc}")

# Contratos de lifecycle dos testes e do AudioManager.
audio_text = (ROOT / "core/audio_manager.gd").read_text(encoding="utf-8")
check("func set_sfx_enabled(" in audio_text, "AudioManager sem chave deterministica para testes")
check("player.stream = null" in audio_text, "AudioManager nao libera referencia do AudioStream")
check("player.free()" in audio_text, "AudioManager sem teardown sincrono dos players")
check("func active_sfx_count()" in audio_text, "AudioManager sem contador de players para gate")

for test_file in ("tests/smoke_test.gd", "tests/flow_transition_test.gd", "tests/main_startup_test.gd"):
    test_text = (ROOT / test_file).read_text(encoding="utf-8")
    check("set_sfx_enabled" in test_text, f"{test_file} nao desabilita SFX no runner headless")
    check('call_deferred("quit"' in test_text, f"{test_file} nao agenda quit depois do teardown")
    check("CACHE_MODE_IGNORE" not in test_text, f"{test_file} usa CACHE_MODE_IGNORE e pode prolongar lifetime de resources")

smoke_text = (ROOT / "tests/smoke_test.gd").read_text(encoding="utf-8")
check("instance.free()" in smoke_text, "smoke nao destrói cenas sincronamente")
check("ZOOQUEST_SMOKE_TEARDOWN=PASS" in smoke_text, "smoke sem gate explicito de teardown")

flow_text = (ROOT / "tests/flow_transition_test.gd").read_text(encoding="utf-8")
check("const MainScene := preload" not in flow_text, "flow mantem PackedScene global ate o shutdown")
check("main.free()" in flow_text, "flow nao destrói Main sincronamente")
check("ZOOQUEST_FLOW_TEARDOWN=PASS" in flow_text, "flow sem gate explicito de teardown")

main_test_text = (ROOT / "tests/main_startup_test.gd").read_text(encoding="utf-8")
check('str(game_state.get("current_phase")) != "menu"' in main_test_text, "startup nao valida fase menu")
check("StageHost" in main_test_text, "startup nao valida StageHost")
check("ZOOQUEST_MAIN_STARTUP_TEARDOWN=PASS" in main_test_text, "startup sem gate explicito de teardown")

log_audit = (ROOT / "scripts/check_godot_logs.sh").read_text(encoding="utf-8")
check("ObjectDB instances.*leaked at exit" in log_audit, "log audit nao cobre ObjectDB leaks")
check("resources still in use at exit" in log_audit, "log audit nao cobre Resource leaks")

for m in re.finditer(r"(?m)^\s*-?\s*uses:\s*([^@\s]+)@([^\s#]+)", workflow):
    action, ref = m.groups()
    if action.startswith("./"):
        continue
    check(bool(re.fullmatch(r"[0-9a-fA-F]{40}", ref)), f"Action nao pinada em SHA: {action}@{ref}")

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
