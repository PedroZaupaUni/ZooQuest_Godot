#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"

python3 scripts/validate_repository.py
python3 scripts/validate_runtime_patterns.py
python3 scripts/audit_repository.py

git diff --check

echo "ZOOQUEST_PRE_PR_CHECK=PASS"
