#!/usr/bin/env bash
set -Eeuo pipefail
EVENT_NAME="${1:-${GITHUB_EVENT_NAME:-local}}"
BASE_REF="${2:-${GITHUB_BASE_REF:-}}"
HEAD_REF="${3:-${GITHUB_HEAD_REF:-$(git branch --show-current 2>/dev/null || true)}}"

if [[ "$EVENT_NAME" != 'pull_request' ]]; then
  echo "ZOOQUEST_BRANCH_POLICY=PASS event=$EVENT_NAME"
  exit 0
fi

case "$BASE_REF" in
  main)
    if [[ "$HEAD_REF" != 'develop' ]]; then
      echo "ZOOQUEST_BRANCH_POLICY=FAIL base=main head=$HEAD_REF expected=develop" >&2
      exit 1
    fi
    ;;
  develop)
    if [[ ! "$HEAD_REF" =~ ^(feature|fix|chore|docs|test|hotfix)/[A-Za-z0-9._/-]+$ ]]; then
      echo "ZOOQUEST_BRANCH_POLICY=FAIL base=develop head=$HEAD_REF" >&2
      echo 'Use feature/*, fix/*, chore/*, docs/*, test/* ou hotfix/*.' >&2
      exit 1
    fi
    ;;
  *)
    echo "ZOOQUEST_BRANCH_POLICY=FAIL unsupported_base=$BASE_REF" >&2
    exit 1
    ;;
esac

echo "ZOOQUEST_BRANCH_POLICY=PASS base=$BASE_REF head=$HEAD_REF"
