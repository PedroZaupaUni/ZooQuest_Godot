#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(git rev-parse --show-toplevel)"
cd "$ROOT"
git config core.hooksPath .githooks
chmod +x .githooks/pre-push
echo "ZOOQUEST_GIT_HOOKS=INSTALLED"
echo "core.hooksPath=$(git config core.hooksPath)"
