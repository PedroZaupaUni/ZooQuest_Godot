# ZooQuest - CI Harness FIX2.2

## Motivo

O run da PR #1 falhou em `tests/smoke_test.gd` porque `var instance := resource.instantiate()` dependia de inferencia de tipo que o parser do Godot 4.7.2 nao conseguiu resolver.

## Correcao

- `Resource` e `PackedScene` agora sao tipados explicitamente.
- A instancia da cena e declarada como `Node`.
- Smoke timeout reduzido de 90s para 30s.
- Flow timeout ajustado para 45s.
- Em falha/timeout, stdout e log do Godot sao impressos antes do job encerrar.
- A mesma robustez foi aplicada ao runner local `scripts/run_godot_smoke.sh`.

## Gate

O FIX2.2 nao autoriza merge por si so. A PR #1 so pode ser mergeada quando `repository-audit` e `godot-tests` terminarem com sucesso. Depois do merge, a CI de `main` deve passar antes da ativacao do ruleset.
