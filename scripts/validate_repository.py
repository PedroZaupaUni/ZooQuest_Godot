#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import sys
import wave
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
warnings: list[str] = []
checks: list[tuple[str, bool, str]] = []


def check(name: str, condition: bool, detail: str) -> None:
    checks.append((name, bool(condition), detail))
    if not condition:
        errors.append(f"{name}: {detail}")


required = [
    "project.godot",
    "README.md",
    "CONTRIBUTING.md",
    "core/main.tscn",
    "core/main.gd",
    "core/game_state.gd",
    "data/questions.json",
    "data/story_flow.json",
    "data/question_bank.gd",
    "ui/main_menu.tscn",
    "ui/narrative_screen.tscn",
    "ui/transformation_screen.tscn",
    "ui/ending_screen.tscn",
    "ui/hud.tscn",
    "minigames/frog/frog_minigame.tscn",
    "minigames/bird/bird_minigame.tscn",
    "minigames/worm/worm_minigame.tscn",
    "docs/README.md",
    "docs/ARQUITETURA.md",
    "docs/STATUS_DO_PROJETO.md",
    "docs/QUALIDADE_E_TESTES.md",
    "docs/GOVERNANCA_GITHUB.md",
    "docs/REQUISITOS_E_RASTREABILIDADE.md",
    "tests/manual/ROTEIRO_TESTE_FUNCIONAL.md",
]
for rel in required:
    check(f"required:{rel}", (ROOT / rel).is_file(), "arquivo obrigatório presente")

project = (ROOT / "project.godot").read_text(encoding="utf-8")
check("main_scene", 'run/main_scene="res://core/main.tscn"' in project, "cena principal configurada")
for autoload in ("GameState", "QuestionBank", "FlowRepository", "AudioManager"):
    check(f"autoload:{autoload}", f'{autoload}="*res://' in project, "autoload configurado")

res_refs: set[str] = set()
for path in list(ROOT.rglob("*.gd")) + list(ROOT.rglob("*.tscn")) + [ROOT / "project.godot"]:
    if ".godot" in path.parts:
        continue
    text = path.read_text(encoding="utf-8")
    for match in re.findall(r"res://[A-Za-z0-9_./-]+", text):
        res_refs.add(match[len("res://"):])
missing_refs = sorted(ref for ref in res_refs if not (ROOT / ref).exists())
check(
    "resource_references",
    not missing_refs,
    "referências res:// resolvidas" if not missing_refs else str(missing_refs),
)

try:
    questions = json.loads((ROOT / "data/questions.json").read_text(encoding="utf-8"))
except Exception as exc:
    questions = {}
    errors.append(f"questions_json: {exc}")

check("question_phases", set(questions.keys()) == {"frog", "bird", "worm"}, "três fases cadastradas")
question_ids: list[str] = []
for phase in ("frog", "bird", "worm"):
    phase_questions = questions.get(phase, [])
    check(f"questions_count:{phase}", len(phase_questions) == 3, "exatamente três perguntas")
    for question in phase_questions:
        qid = str(question.get("id", ""))
        question_ids.append(qid)
        options = question.get("options", [])
        index = question.get("correct_index", -1)
        shape_ok = (
            bool(qid)
            and bool(question.get("question"))
            and len(options) == 3
            and isinstance(index, int)
            and 0 <= index < 3
            and bool(question.get("explanation"))
        )
        check(f"question_shape:{qid}", shape_ok, "contrato completo")
check("question_id_uniqueness", len(question_ids) == len(set(question_ids)), "IDs únicos")

try:
    flow = json.loads((ROOT / "data/story_flow.json").read_text(encoding="utf-8"))
except Exception as exc:
    flow = []
    errors.append(f"flow_json: {exc}")

expected_ids = [
    "intro",
    "transform_frog",
    "frog_game",
    "return_human_1",
    "between_frog_bird",
    "transform_bird",
    "bird_game",
    "return_human_2",
    "between_bird_worm",
    "transform_worm",
    "worm_game",
    "return_human_3",
    "ending",
]
actual_ids = [step.get("id") for step in flow] if isinstance(flow, list) else []
check("flow_order", actual_ids == expected_ids, "fluxo completo e ordenado")
mini_phases = [step.get("phase") for step in flow if step.get("kind") == "minigame"] if isinstance(flow, list) else []
check("flow_minigames", mini_phases == ["frog", "bird", "worm"], "mini-games na ordem esperada")
returns = [step for step in flow if str(step.get("id", "")).startswith("return_human")]
check(
    "return_human_after_each_phase",
    len(returns) == 3 and all(step.get("to") == "human" for step in returns),
    "retorno humano após cada fase",
)


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
        char = text[i]
        if char == "\n":
            line += 1
        if in_string:
            if escape:
                escape = False
            elif char == "\\":
                escape = True
            elif char == quote:
                in_string = False
            i += 1
            continue
        if char in ('"', "'"):
            in_string = True
            quote = char
            i += 1
            continue
        if char == "#":
            next_line = text.find("\n", i)
            if next_line == -1:
                break
            i = next_line
            continue
        if char in opening:
            stack.append((char, line))
        elif char in pairs:
            if not stack or stack[-1][0] != pairs[char]:
                return False, f"delimitador inesperado {char} na linha {line}"
            stack.pop()
        i += 1
    if in_string:
        return False, "string não finalizada"
    if stack:
        return False, f"delimitador não fechado {stack[-1]}"
    return True, "delimitadores balanceados"


for path in ROOT.rglob("*.gd"):
    if ".godot" in path.parts:
        continue
    text = path.read_text(encoding="utf-8")
    ok, detail = lexical_balance(text)
    check(f"gdscript_balance:{path.relative_to(ROOT)}", ok, detail)
    if "\t" in text and re.search(r"(?m)^ +\S", text):
        warnings.append(f"Possível indentação mista: {path.relative_to(ROOT)}")

for path in ROOT.rglob("*.tscn"):
    if ".godot" in path.parts:
        continue
    text = path.read_text(encoding="utf-8")
    check(f"tscn_header:{path.relative_to(ROOT)}", text.startswith("[gd_scene"), "cabeçalho presente")
    check(f"tscn_root:{path.relative_to(ROOT)}", "[node name=" in text, "nó raiz presente")

for name in ("click.wav", "correct.wav", "wrong.wav", "transform.wav", "finish.wav"):
    path = ROOT / "assets/audio/sfx" / name
    try:
        with wave.open(str(path), "rb") as wav:
            valid = wav.getnchannels() == 1 and wav.getsampwidth() == 2 and wav.getnframes() > 0
    except Exception:
        valid = False
    check(f"wav:{name}", valid, "WAV PCM mono válido")

source_files = [
    "ORIENTACOES_UNIFIL_JOGOS.pdf",
    "VISAO_ZOOQUEST.pdf",
    "GDD_ZOOQUEST.pdf",
    "PROJETO_PI_FINDIT_HISTORICO.pdf",
    "DOCUMENTACAO_GAMEPLAY_E_FLUXOS.docx",
    "CASOS_DE_USO_ZOOQUEST.asta",
]
for name in source_files:
    check(f"source:{name}", (ROOT / "docs/referencias" / name).is_file(), "referência preservada")

status = "PASS" if not errors else "FAIL"
print("ZOOQUEST_VALIDATION_STATUS=" + status)
print(f"CHECKS_TOTAL={len(checks)}")
print(f"CHECKS_PASSED={sum(1 for _, passed, _ in checks if passed)}")
print(f"ERRORS={len(errors)}")
print(f"WARNINGS={len(warnings)}")
for warning in warnings:
    print("WARNING: " + warning)
for error in errors:
    print("ERROR: " + error)
sys.exit(1 if errors else 0)
