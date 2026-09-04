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

GODOT_VERSION_ACTUAL="$("$GODOT" --version | head -n 1)"
echo "GODOT_VERSION_ACTUAL=$GODOT_VERSION_ACTUAL"
if [[ "$GODOT_VERSION_ACTUAL" != 4.7.2* ]]; then
  echo "GODOT_VERSION_GATE=FAIL"
  echo "Esperado Godot 4.7.2, obtido: $GODOT_VERSION_ACTUAL"
  exit 3
fi

TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

print_logs() {
  local prefix="$1"
  for file in "$TMP/${prefix}.stdout" "$TMP/${prefix}.log"; do
    if [[ -f "$file" ]]; then
      echo "===== $file ====="
      cat "$file" || true
    fi
  done
}

run_scene_test() {
  local label="$1"
  local scene="$2"
  local pass_marker="$3"
  local teardown_marker="$4"
  local seconds="$5"
  local prefix="$6"

  echo "== $label =="
  set +e
  timeout "${seconds}s" "$GODOT" --headless --verbose --path "$ROOT" "$scene" \
    --log-file "$TMP/${prefix}.log" 2>&1 | tee "$TMP/${prefix}.stdout"
  local rc=${PIPESTATUS[0]}
  set -e

  if [[ "$rc" -ne 0 ]]; then
    echo "${prefix^^}_PROCESS_RC=$rc"
    print_logs "$prefix"
    ./scripts/check_godot_logs.sh "$TMP/${prefix}.log" "$TMP/${prefix}.stdout" || true
    return "$rc"
  fi

  if ! grep -q "$pass_marker" "$TMP/${prefix}.stdout" "$TMP/${prefix}.log"; then
    echo "${prefix^^}_PASS_MARKER=MISSING"
    print_logs "$prefix"
    return 1
  fi

  if ! grep -q "$teardown_marker" "$TMP/${prefix}.stdout" "$TMP/${prefix}.log"; then
    echo "${prefix^^}_TEARDOWN_MARKER=MISSING"
    print_logs "$prefix"
    return 1
  fi

  ./scripts/check_godot_logs.sh "$TMP/${prefix}.log" "$TMP/${prefix}.stdout"
}

"$GODOT" --headless --verbose --path "$ROOT" --import --quit \
  --log-file "$TMP/import.log" >"$TMP/import.stdout" 2>&1
./scripts/check_godot_logs.sh "$TMP/import.log" "$TMP/import.stdout"

run_scene_test \
  "GODOT SMOKE" \
  "res://tests/smoke_test.tscn" \
  "ZOOQUEST_GODOT_SMOKE=PASS" \
  "ZOOQUEST_SMOKE_TEARDOWN=PASS" \
  20 \
  "smoke"

run_scene_test \
  "GODOT FLOW" \
  "res://tests/flow_transition_test.tscn" \
  "ZOOQUEST_FLOW_TRANSITION_TEST=PASS" \
  "ZOOQUEST_FLOW_TEARDOWN=PASS" \
  30 \
  "flow"

run_scene_test \
  "GODOT MAIN STARTUP" \
  "res://tests/main_startup_test.tscn" \
  "ZOOQUEST_MAIN_STARTUP=PASS" \
  "ZOOQUEST_MAIN_STARTUP_TEARDOWN=PASS" \
  20 \
  "main"

echo "ZOOQUEST_LOCAL_GODOT_TESTS=PASS"
