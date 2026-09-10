#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
CURRENT_BRANCH="$(git branch --show-current)"
if [[ -z "$CURRENT_BRANCH" || "$CURRENT_BRANCH" == 'main' || "$CURRENT_BRANCH" == 'develop' ]]; then
  echo 'ERRO: pre_pr_check deve rodar em branch de trabalho.' >&2
  exit 1
fi
./scripts/validate_branch_policy.sh pull_request develop "$CURRENT_BRANCH"
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_repository.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_runtime_patterns.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/update_repository_metadata.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/audit_repository.py
git diff --check
if ! git diff --quiet -- MANIFEST.sha256 REPOSITORY_INVENTORY.json; then
  echo 'ZOOQUEST_METADATA_REGENERATED=YES'
  echo 'Revise e inclua MANIFEST.sha256 e REPOSITORY_INVENTORY.json no commit.'
fi
if [[ -n "${GODOT_BIN:-}" && -x "${GODOT_BIN}" ]] || command -v godot4 >/dev/null 2>&1 || command -v godot >/dev/null 2>&1; then
  ./scripts/run_godot_smoke.sh
else
  echo 'ZOOQUEST_LOCAL_GODOT=BLOCKED_ENGINE_NOT_FOUND'
  echo 'CI executara o gate oficial com Godot 4.7.2.'
fi
echo 'ZOOQUEST_PRE_PR_CHECK=PASS'
