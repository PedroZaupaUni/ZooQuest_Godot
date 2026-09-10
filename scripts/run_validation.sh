#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_repository.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_runtime_patterns.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/validate_documentation.py
PYTHONDONTWRITEBYTECODE=1 python3 scripts/audit_repository.py
git diff --check
echo 'ZOOQUEST_STATIC_VALIDATION=PASS'
