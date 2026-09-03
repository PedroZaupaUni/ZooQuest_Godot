#!/usr/bin/env python3
from __future__ import annotations

import hashlib
import json
import re
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REPORT_PATH = ROOT / "validation" / "VALIDATION_REPORT.json"

errors: list[str] = []
warnings: list[str] = []
checks: list[dict] = []


def check(name: str, condition: bool, detail: str) -> None:
    checks.append({"name": name, "passed": bool(condition), "detail": detail})
    if not condition:
        errors.append(f"{name}: {detail}")


def sha256(path: Path) -> str:
    h = hashlib.sha256()
    with path.open("rb") as file:
        for chunk in iter(lambda: file.read(1024 * 1024), b""):
            h.update(chunk)
    return h.hexdigest()


required = [
    "project.godot", "core/main.tscn", "core/main.gd", "core/game_state.gd",
    "data/questions.json", "data/story_flow.json", "data/question_bank.gd",
    "ui/main_menu.tscn", "ui/narrative_screen.tscn", "ui/transformation_screen.tscn",
    "ui/ending_screen.tscn", "ui/hud.tscn",
    "minigames/frog/frog_minigame.tscn", "minigames/bird/bird_minigame.tscn",
    "minigames/worm/worm_minigame.tscn", "README.md", "CONTINUE_AQUI.md"
]
for rel in required:
    check(f"required:{rel}", (ROOT / rel).is_file(), "arquivo obrigatorio presente")

project = (ROOT / "project.godot").read_text(encoding="utf-8")
check("main_scene", 'run/main_scene="res://core/main.tscn"' in project, "cena principal configurada")
for autoload in ["GameState", "QuestionBank", "FlowRepository", "AudioManager"]:
    check(f"autoload:{autoload}", f'{autoload}="*res://' in project, "autoload configurado")

# Every res:// path referenced by text scripts/scenes/project must exist.
res_refs: set[str] = set()
for path in list(ROOT.rglob("*.gd")) + list(ROOT.rglob("*.tscn")) + [ROOT / "project.godot"]:
    text = path.read_text(encoding="utf-8")
    for match in re.findall(r'res://[A-Za-z0-9_./-]+', text):
        res_refs.add(match[len("res://"):])
missing_refs = sorted(ref for ref in res_refs if not (ROOT / ref).exists())
check("resource_references", not missing_refs, "referencias res:// resolvidas" if not missing_refs else str(missing_refs))

# JSON contracts.
try:
    questions = json.loads((ROOT / "data/questions.json").read_text(encoding="utf-8"))
except Exception as exc:
    questions = {}
    errors.append(f"questions_json: {exc}")

check("question_phases", set(questions.keys()) == {"frog", "bird", "worm"}, "tres fases cadastradas")
question_ids: list[str] = []
for phase in ["frog", "bird", "worm"]:
    phase_questions = questions.get(phase, [])
    check(f"questions_count:{phase}", len(phase_questions) == 3, "exatamente tres perguntas")
    for q in phase_questions:
        qid = str(q.get("id", ""))
        question_ids.append(qid)
        options = q.get("options", [])
        idx = q.get("correct_index", -1)
        check(f"question_shape:{qid}", bool(qid) and bool(q.get("question")) and len(options) == 3 and isinstance(idx, int) and 0 <= idx < 3 and bool(q.get("explanation")), "contrato completo")
check("question_id_uniqueness", len(question_ids) == len(set(question_ids)), "IDs unicos")

try:
    flow = json.loads((ROOT / "data/story_flow.json").read_text(encoding="utf-8"))
except Exception as exc:
    flow = []
    errors.append(f"flow_json: {exc}")

expected_ids = [
    "intro", "transform_frog", "frog_game", "return_human_1", "between_frog_bird",
    "transform_bird", "bird_game", "return_human_2", "between_bird_worm",
    "transform_worm", "worm_game", "return_human_3", "ending"
]
actual_ids = [step.get("id") for step in flow] if isinstance(flow, list) else []
check("flow_order", actual_ids == expected_ids, "fluxo completo e ordenado")
mini_phases = [step.get("phase") for step in flow if step.get("kind") == "minigame"] if isinstance(flow, list) else []
check("flow_minigames", mini_phases == ["frog", "bird", "worm"], "tres mini-games na ordem canonica")
returns = [step for step in flow if str(step.get("id", "")).startswith("return_human")]
check("return_human_after_each_phase", len(returns) == 3 and all(step.get("to") == "human" for step in returns), "retorno humano apos cada fase")

# Lightweight lexical balance for GDScript files.
def lexical_balance(text: str) -> tuple[bool, str]:
    stack: list[tuple[str, int]] = []
    pairs = {")": "(", "]": "[", "}": "{"}
    opening = set(pairs.values())
    in_string = False
    quote = ""
    escape = False
    line = 1
    i = 0
    while i < len(text):
        ch = text[i]
        if ch == "\n":
            line += 1
        if in_string:
            if escape:
                escape = False
            elif ch == "\\":
                escape = True
            elif ch == quote:
                in_string = False
            i += 1
            continue
        if ch in ('"', "'"):
            in_string = True
            quote = ch
            i += 1
            continue
        if ch == "#":
            next_line = text.find("\n", i)
            if next_line == -1:
                break
            i = next_line
            continue
        if ch in opening:
            stack.append((ch, line))
        elif ch in pairs:
            if not stack or stack[-1][0] != pairs[ch]:
                return False, f"delimitador inesperado {ch} na linha {line}"
            stack.pop()
        i += 1
    if in_string:
        return False, "string nao finalizada"
    if stack:
        return False, f"delimitador nao fechado {stack[-1]}"
    return True, "delimitadores balanceados"

for path in ROOT.rglob("*.gd"):
    ok, detail = lexical_balance(path.read_text(encoding="utf-8"))
    check(f"gdscript_balance:{path.relative_to(ROOT)}", ok, detail)
    text = path.read_text(encoding="utf-8")
    if "\t" in text and re.search(r"(?m)^ +\S", text):
        warnings.append(f"Indentacao mista possivel: {path.relative_to(ROOT)}")

# TSCN minimal shape.
for path in ROOT.rglob("*.tscn"):
    text = path.read_text(encoding="utf-8")
    check(f"tscn_header:{path.relative_to(ROOT)}", text.startswith("[gd_scene"), "cabecalho de cena presente")
    check(f"tscn_root:{path.relative_to(ROOT)}", "[node name=" in text, "no raiz presente")

# WAVs are readable and local.
for name in ["click.wav", "correct.wav", "wrong.wav", "transform.wav", "finish.wav"]:
    path = ROOT / "assets/audio/sfx" / name
    try:
        with wave.open(str(path), "rb") as wav:
            valid = wav.getnchannels() == 1 and wav.getsampwidth() == 2 and wav.getnframes() > 0
    except Exception:
        valid = False
    check(f"wav:{name}", valid, "WAV PCM mono valido")

# Required source documentation.
source_files = [
    "Orientacoes_UniFil_Jogos.pdf", "Visao_ZooQuest.pdf", "GDD_ZooQuest.pdf",
    "Projeto_PI_FindIt_Historico.pdf", "Documentacao_Gameplay_e_Fluxos.docx",
    "Casos_de_Uso_ZooQuest.asta"
]
for name in source_files:
    check(f"source:{name}", (ROOT / "docs/fontes" / name).is_file(), "fonte preservada")

status = "PASS" if not errors else "FAIL"
report = {
    "project": "ZooQuest: A Jornada do Aprendizado",
    "validation_type": "static_repository_validation",
    "status": status,
    "checks_total": len(checks),
    "checks_passed": sum(1 for item in checks if item["passed"]),
    "errors": errors,
    "warnings": warnings,
    "checks": checks,
    "runtime_note": "A execucao dentro do motor Godot deve ser confirmada com tests/manual/ROTEIRO_TESTE_FUNCIONAL.md.",
}
REPORT_PATH.parent.mkdir(parents=True, exist_ok=True)
REPORT_PATH.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")

print("ZOOQUEST_VALIDATION_STATUS=" + status)
print(f"CHECKS_TOTAL={len(checks)}")
print(f"CHECKS_PASSED={report['checks_passed']}")
print(f"ERRORS={len(errors)}")
print(f"WARNINGS={len(warnings)}")
print("REPORT=" + str(REPORT_PATH))
if errors:
    for error in errors:
        print("ERROR: " + error)
    sys.exit(1)
