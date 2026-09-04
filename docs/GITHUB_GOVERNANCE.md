# Governanca GitHub - ZooQuest

## Objetivo

Proteger a branch `main` contra alteracoes concorrentes ou nao revisadas e transformar CI, testes Godot e auditorias do repositorio em gates de merge.

## Gates obrigatorios

1. Pull Request obrigatorio.
2. Uma aprovacao.
3. Ultimo push aprovado por outra pessoa.
4. Reviews antigos descartados apos novos commits.
5. Todas as threads resolvidas.
6. `repository-audit` verde.
7. `godot-tests` verde.
8. Squash merge apenas.
9. Historico linear.
10. Sem force push ou exclusao de `main`.

## CI

`repository-audit` executa:

- `scripts/validate_repository.py`;
- `scripts/validate_runtime_patterns.py`;
- `scripts/audit_repository.py`;
- `git diff --check` em PRs.

`godot-tests` baixa o Godot 4.7.2 oficial e executa:

- importacao headless;
- `tests/smoke_test.gd`;
- `tests/flow_transition_test.gd`;
- startup headless da main scene e busca por erros criticos.

## Actions security

O workflow declara `permissions: contents: read`, nao usa `pull_request_target` e a action de checkout e fixada em SHA completo.

## CODEOWNERS

O arquivo `.github/CODEOWNERS` solicita `@PedroZaupaUni` para review. Quando os GitHub handles dos demais responsaveis forem definidos, ownership por fase pode ser adicionado sem mudar o ruleset.
