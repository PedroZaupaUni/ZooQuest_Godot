#!/usr/bin/env bash
set -Eeuo pipefail

if [[ "$#" -lt 1 ]]; then
  echo "Uso: $0 <log1> [log2 ...]" >&2
  exit 2
fi

PATTERN='SCRIPT ERROR:|Compile Error:|Parse Error:|Parser Error:|Failed to load script|Invalid call|Cannot call method|Invalid get index|Invalid access|ObjectDB instances.*leaked at exit|resources still in use at exit|Leaked instance:|Leaked resource:|^ERROR:'

if grep -Ein "$PATTERN" "$@" 2>/dev/null; then
  echo "ZOOQUEST_GODOT_LOG_AUDIT=FAIL"
  exit 1
fi

echo "ZOOQUEST_GODOT_LOG_AUDIT=PASS"
