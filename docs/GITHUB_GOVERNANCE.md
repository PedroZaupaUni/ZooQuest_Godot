# Governanca GitHub - ZooQuest

## Fluxo canonico

`feature/* | fix/* | chore/* | docs/* | test/* | hotfix/* -> develop -> main`

## Gates obrigatorios

1. Pull Request.
2. `branch-policy`.
3. `repository-audit`.
4. `godot-tests`.
5. Todas as threads abertas resolvidas.
6. Sem force push.
7. Sem exclusao das branches protegidas.

## Review humano

Review humano e opcional.

O mantenedor responsavel pode fazer merge do proprio Pull Request quando
todos os gates automaticos obrigatorios estiverem verdes.

Essa politica evita dependencia operacional de uma segunda pessoa sem
remover os controles tecnicos do repositorio.

## Merge

- branches de trabalho -> `develop`: Squash.
- `develop` -> `main`: Merge Commit.

## Status checks

`develop` usa checks strict.

`main` exige os mesmos checks, mas usa
`strict_required_status_checks_policy=false` para preservar a genealogia
do Git flow sem exigir `main -> develop`.

## CI

A CI cobre `develop` e `main`.

Gates:

- `branch-policy`;
- `repository-audit`;
- `godot-tests`.

O runtime usa Godot 4.7.2 verificado por SHA-256.
