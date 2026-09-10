#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
CURRENT_BRANCH="$(git branch --show-current)"
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == 'main' || "$CURRENT_BRANCH" == 'develop' ]]; then
    echo 'ERRO: execute o pre-PR em uma branch de trabalho.' >&2
    exit 1
fi
./scripts/validate_branch_policy.sh pull_request develop "$CURRENT_BRANCH"
./scripts/run_validation.sh
if [[ -n "${GODOT_BIN:-}" && -x "${GODOT_BIN}" ]] || command -v godot4 >/dev/null 2>&1 || command -v godot >/dev/null 2>&1; then
    ./scripts/run_godot_smoke.sh
else
    echo 'ZOOQUEST_LOCAL_GODOT=SKIPPED_ENGINE_NOT_FOUND'
    echo 'A CI executará o gate oficial com Godot 4.7.2.'
fi
echo 'ZOOQUEST_PRE_PR_CHECK=PASS'
