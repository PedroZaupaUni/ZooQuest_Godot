#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [[ -n "${GODOT_BIN:-}" && -x "${GODOT_BIN}" ]]; then
  GODOT="${GODOT_BIN}"
elif command -v godot4 >/dev/null 2>&1; then
  GODOT="$(command -v godot4)"
elif command -v godot >/dev/null 2>&1; then
  GODOT="$(command -v godot)"
else
  echo "GODOT_SMOKE=BLOCKED_ENGINE_NOT_FOUND"
  echo "Defina GODOT_BIN=/caminho/para/Godot ou instale Godot 4.x."
  exit 2
fi

"$GODOT" --headless --path "$ROOT" --editor --quit-after 8
"$GODOT" --headless --path "$ROOT" --script res://tests/smoke_test.gd
