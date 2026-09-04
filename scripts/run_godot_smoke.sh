#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"

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

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

"$GODOT" --headless --path "$ROOT" --import --quit --log-file "$TMP/import.log" >"$TMP/import.stdout" 2>&1
./scripts/check_godot_logs.sh "$TMP/import.log" "$TMP/import.stdout"

timeout 90s "$GODOT" --headless --path "$ROOT" res://tests/smoke_test.tscn --log-file "$TMP/smoke.log" 2>&1 | tee "$TMP/smoke.stdout"
grep -q 'ZOOQUEST_GODOT_SMOKE=PASS' "$TMP/smoke.stdout" "$TMP/smoke.log"
./scripts/check_godot_logs.sh "$TMP/smoke.log" "$TMP/smoke.stdout"

timeout 90s "$GODOT" --headless --path "$ROOT" res://tests/flow_transition_test.tscn --log-file "$TMP/flow.log" 2>&1 | tee "$TMP/flow.stdout"
grep -q 'ZOOQUEST_FLOW_TRANSITION_TEST=PASS' "$TMP/flow.stdout" "$TMP/flow.log"
./scripts/check_godot_logs.sh "$TMP/flow.log" "$TMP/flow.stdout"

echo "ZOOQUEST_LOCAL_GODOT_TESTS=PASS"
