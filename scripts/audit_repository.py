#!/usr/bin/env python3
from __future__ import annotations

import json
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
errors: list[str] = []
checks = 0


def check(condition: bool, message: str) -> None:
    global checks
    checks += 1
    if not condition:
        errors.append(message)


def tracked_files() -> list[Path]:
    proc = subprocess.run(
        ["git", "ls-files", "-z"],
        cwd=ROOT,
        check=True,
        stdout=subprocess.PIPE,
    )
    return [ROOT / item.decode("utf-8") for item in proc.stdout.split(b"\0") if item]


files = tracked_files()
relative = [path.relative_to(ROOT).as_posix() for path in files]

for path in relative:
    check(not path.startswith(".godot/"), f"arquivo gerado do Godot rastreado: {path}")
    check(not path.startswith("validation/"), f"saída histórica de validação rastreada: {path}")
    check(not path.endswith((".log", ".tmp", ".swp", ".pyc")), f"temporário/cache rastreado: {path}")
    check("/__pycache__/" not in ("/" + path), f"cache Python rastreado: {path}")
    check(not path.endswith(".patch"), f"patch operacional rastreado: {path}")

for obsolete in ("MANIFEST.sha256", "REPOSITORY_INVENTORY.json", "scripts/update_repository_metadata.py"):
    check(obsolete not in relative, f"metadado redundante ainda rastreado: {obsolete}")

max_bytes = 25 * 1024 * 1024
for path in files:
    if path.exists() and path.is_file():
        check(path.stat().st_size <= max_bytes, f"arquivo maior que 25 MiB: {path.relative_to(ROOT)}")

required = [
    "project.godot",
    "README.md",
    "CONTRIBUTING.md",
    "core/main.gd",
    "core/audio_manager.gd",
    "data/questions.json",
    "data/story_flow.json",
    "scripts/validate_repository.py",
    "scripts/validate_runtime_patterns.py",
    "scripts/validate_documentation.py",
    "scripts/audit_repository.py",
    "scripts/run_validation.sh",
    "scripts/check_godot_logs.sh",
    "scripts/run_godot_smoke.sh",
    "scripts/pre_pr_check.sh",
    "scripts/validate_branch_policy.sh",
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
    "docs/README.md",
    "docs/ARQUITETURA.md",
    "docs/STATUS_DO_PROJETO.md",
    "docs/QUALIDADE_E_TESTES.md",
    "docs/GOVERNANCA_GITHUB.md",
]
for item in required:
    check((ROOT / item).is_file(), f"arquivo obrigatório ausente: {item}")

for item in ("data/questions.json", "data/story_flow.json"):
    try:
        json.loads((ROOT / item).read_text(encoding="utf-8"))
        check(True, f"JSON válido: {item}")
    except Exception as exc:
        check(False, f"JSON inválido {item}: {exc}")

project_text = (ROOT / "project.godot").read_text(encoding="utf-8", errors="replace")
check('run/main_scene="res://core/main.tscn"' in project_text, "project.godot sem cena principal canônica")
for autoload in ("GameState", "QuestionBank", "FlowRepository", "AudioManager"):
    check(f'{autoload}="*res://' in project_text, f"autoload ausente: {autoload}")

workflow = (ROOT / ".github/workflows/ci.yml").read_text(encoding="utf-8")
check("pull_request_target" not in workflow, "workflow usa pull_request_target")
check(re.search(r"(?m)^permissions:\s*$", workflow) is not None, "workflow sem bloco permissions")
check(re.search(r"(?m)^\s{2}contents:\s*read\s*$", workflow) is not None, "GITHUB_TOKEN não está contents: read")
check(workflow.count("branches: [main, develop]") >= 2, "CI não cobre main e develop")
check("run_validation.sh" in workflow, "CI não executa validador central")
check("validate_documentation.py" in (ROOT / "scripts/run_validation.sh").read_text(encoding="utf-8"), "validação central não cobre documentação")
check("branch-policy" in workflow, "CI sem branch-policy")
check("validate_branch_policy.sh" in workflow, "CI não executa política de branches")
check("smoke_test.tscn" in workflow, "CI não executa smoke")
check("flow_transition_test.tscn" in workflow, "CI não executa fluxo completo")
check("main_startup_test.tscn" in workflow, "CI não executa startup da Main")
check("check_godot_logs.sh" in workflow, "CI não audita logs Godot")
check("--verbose" in workflow, "CI Godot sem modo verbose")
check("GODOT_SHA256" in workflow and "sha256sum -c" in workflow, "CI não valida SHA-256 do Godot")
check("Godot_v4.7.2-stable_linux.x86_64.zip" in workflow, "CI não fixa Godot 4.7.2")

branch_policy = (ROOT / "scripts/validate_branch_policy.sh").read_text(encoding="utf-8")
check("HEAD_REF" in branch_policy and "BASE_REF" in branch_policy, "branch-policy sem refs de PR")
check("base=main" in branch_policy and "expected=develop" in branch_policy, "branch-policy sem regra main <- develop")
check("base=develop" in branch_policy and "feature|fix|chore|docs|test|hotfix" in branch_policy, "branch-policy sem branches de trabalho")

for ruleset_path, expected_ref, expected_method, expected_strict, linear in (
    (".github/rulesets/main-protection.json", "~DEFAULT_BRANCH", "merge", False, False),
    (".github/rulesets/develop-protection.json", "refs/heads/develop", "squash", True, True),
):
    try:
        ruleset = json.loads((ROOT / ruleset_path).read_text(encoding="utf-8"))
        includes = ruleset.get("conditions", {}).get("ref_name", {}).get("include", [])
        check(expected_ref in includes, f"ruleset {ruleset_path} não protege {expected_ref}")
        rule_types = {rule.get("type") for rule in ruleset.get("rules", [])}
        check("deletion" in rule_types, f"ruleset {ruleset_path} permite exclusão")
        check("non_fast_forward" in rule_types, f"ruleset {ruleset_path} permite non-fast-forward")
        check(("required_linear_history" in rule_types) is linear, f"ruleset {ruleset_path} linear history incorreto")
        contexts: list[str | None] = []
        pull_methods: list[str] = []
        strict_value = None
        approval_count = None
        last_push_approval = None
        thread_resolution = None
        for rule in ruleset.get("rules", []):
            if rule.get("type") == "required_status_checks":
                params = rule.get("parameters", {})
                contexts = [item.get("context") for item in params.get("required_status_checks", [])]
                strict_value = params.get("strict_required_status_checks_policy")
            if rule.get("type") == "pull_request":
                params = rule.get("parameters", {})
                pull_methods = params.get("allowed_merge_methods", [])
                approval_count = params.get("required_approving_review_count")
                last_push_approval = params.get("require_last_push_approval")
                thread_resolution = params.get("required_review_thread_resolution")
        for context in ("branch-policy", "repository-audit", "godot-tests"):
            check(context in contexts, f"ruleset {ruleset_path} sem check {context}")
        check(pull_methods == [expected_method], f"ruleset {ruleset_path} método de merge incorreto")
        check(strict_value is expected_strict, f"ruleset {ruleset_path} strict policy incorreta")
        check(approval_count == 0, f"ruleset {ruleset_path} voltou a exigir aprovação humana")
        check(last_push_approval is False, f"ruleset {ruleset_path} exige aprovação do último push")
        check(thread_resolution is True, f"ruleset {ruleset_path} não exige resolução de threads")
    except Exception as exc:
        check(False, f"ruleset inválido {ruleset_path}: {exc}")

audio_text = (ROOT / "core/audio_manager.gd").read_text(encoding="utf-8")
check("func set_sfx_enabled(" in audio_text, "AudioManager sem controle determinístico de SFX")
check("player.stream = null" in audio_text, "AudioManager não libera AudioStream")
check("player.free()" in audio_text, "AudioManager sem teardown síncrono")
check("func active_sfx_count()" in audio_text, "AudioManager sem contador de players")

for test_file in ("tests/smoke_test.gd", "tests/flow_transition_test.gd", "tests/main_startup_test.gd"):
    text = (ROOT / test_file).read_text(encoding="utf-8")
    check("set_sfx_enabled" in text, f"{test_file} não desabilita SFX no headless")
    check('call_deferred("quit"' in text, f"{test_file} não encerra depois do teardown")
    check("CACHE_MODE_IGNORE" not in text, f"{test_file} usa CACHE_MODE_IGNORE")

smoke = (ROOT / "tests/smoke_test.gd").read_text(encoding="utf-8")
check("instance.free()" in smoke, "smoke não destrói instâncias sincronamente")
check("ZOOQUEST_SMOKE_TEARDOWN=PASS" in smoke, "smoke sem gate de teardown")

flow = (ROOT / "tests/flow_transition_test.gd").read_text(encoding="utf-8")
check("main.free()" in flow, "flow não destrói Main sincronamente")
check("ZOOQUEST_FLOW_TEARDOWN=PASS" in flow, "flow sem gate de teardown")

startup = (ROOT / "tests/main_startup_test.gd").read_text(encoding="utf-8")
check("StageHost" in startup, "startup não valida StageHost")
check("ZOOQUEST_MAIN_STARTUP_TEARDOWN=PASS" in startup, "startup sem gate de teardown")

log_audit = (ROOT / "scripts/check_godot_logs.sh").read_text(encoding="utf-8")
check("ObjectDB instances.*leaked at exit" in log_audit, "log audit não cobre ObjectDB leaks")
check("resources still in use at exit" in log_audit, "log audit não cobre Resource leaks")

for match in re.finditer(r"(?m)^\s*-?\s*uses:\s*([^@\s]+)@([^\s#]+)", workflow):
    action, ref = match.groups()
    if action.startswith("./"):
        continue
    check(bool(re.fullmatch(r"[0-9a-fA-F]{40}", ref)), f"Action não pinada em SHA: {action}@{ref}")

text_suffixes = {".gd", ".tscn", ".tres", ".json", ".yml", ".yaml", ".md", ".cfg", ".godot", ".py", ".sh"}
for path in files:
    if path.suffix.lower() not in text_suffixes and path.name != "project.godot":
        continue
    try:
        text = path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        continue
    conflict = bool(re.search(r"(?m)^<<<<<<< |^>>>>>>> |^=======$", text))
    check(not conflict, f"marcador de conflito Git: {path.relative_to(ROOT)}")

status = "PASS" if not errors else "FAIL"
print("ZOOQUEST_REPOSITORY_AUDIT=" + status)
print(f"CHECKS_TOTAL={checks}")
print(f"ERRORS={len(errors)}")
for error in errors:
    print("ERROR " + error)
sys.exit(1 if errors else 0)
