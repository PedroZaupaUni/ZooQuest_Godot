#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

python3 scripts/validate_repository.py
python3 scripts/validate_runtime_patterns.py
python3 scripts/audit_repository.py

git diff --check

if [[ -n "${GODOT_BIN:-}" && -x "${GODOT_BIN}" ]] || command -v godot4 >/dev/null 2>&1 || command -v godot >/dev/null 2>&1; then
  ./scripts/run_godot_smoke.sh
else
  echo "ZOOQUEST_LOCAL_GODOT=BLOCKED_ENGINE_NOT_FOUND"
  echo "CI executara os testes oficiais com Godot 4.7.2."
fi

echo "ZOOQUEST_PRE_PR_CHECK=PASS"
