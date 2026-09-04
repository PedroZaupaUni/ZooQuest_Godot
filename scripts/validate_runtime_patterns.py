#!/usr/bin/env python3
from pathlib import Path
import re
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
checks = []

def ok(name, cond, detail):
    checks.append((name, cond, detail))
    if not cond:
        errors.append(f"{name}: {detail}")

# Regression for the crash observed in Godot:
# a stage-changing callback must not run before set_input_as_handled in keyboard handlers.
for rel, action in [
    ('ui/transformation_screen.gd', '_on_continue_pressed()'),
    ('ui/narrative_screen.gd', '_on_next_pressed()'),
]:
    text = (ROOT / rel).read_text(encoding='utf-8')
    handler = re.search(r'func _unhandled_key_input\(.*?\n(?=func |\Z)', text, re.S)
    body = handler.group(0) if handler else ''
    handled_pos = body.find('set_input_as_handled()')
    action_pos = body.find(action)
    ok(
        f'lifecycle_input_order:{rel}',
        handled_pos >= 0 and action_pos >= 0 and handled_pos < action_pos,
        'input deve ser marcado como tratado antes de emitir/trocar etapa',
    )
    ok(
        f'lifecycle_viewport_guard:{rel}',
        'if viewport != null:' in body,
        'viewport protegido contra null',
    )

main = (ROOT / 'core/main.gd').read_text(encoding='utf-8')
for token in ['start_requested', 'finished', 'menu_requested', 'completed', 'replay_requested']:
    lines = [line for line in main.splitlines() if f'{token}.connect(' in line]
    ok(
        f'deferred_navigation:{token}',
        bool(lines) and all('CONNECT_DEFERRED' in line for line in lines),
        'sinais que alteram StageHost devem usar CONNECT_DEFERRED',
    )

for rel in [
    'minigames/frog/frog_minigame.gd',
    'minigames/bird/bird_minigame.gd',
    'minigames/worm/worm_minigame.gd',
]:
    text=(ROOT/rel).read_text(encoding='utf-8')
    waits=text.count('await ')
    guards=text.count('if not is_inside_tree():')
    ok(f'async_tree_guards:{rel}', guards >= 2, f'awaits={waits}, guards={guards}')

print('ZOOQUEST_RUNTIME_PATTERN_VALIDATION=' + ('PASS' if not errors else 'FAIL'))
print('CHECKS_TOTAL=' + str(len(checks)))
print('CHECKS_PASSED=' + str(sum(1 for _,c,_ in checks if c)))
for name, cond, detail in checks:
    print(('PASS' if cond else 'FAIL') + ' ' + name + ' :: ' + detail)
if errors:
    print('ERRORS=' + str(len(errors)))
    for error in errors:
        print('ERROR ' + error)
    sys.exit(1)
print('ERRORS=0')
