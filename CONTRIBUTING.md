# Contribuindo com o ZooQuest

## Branches canonicas

- `main`: baseline estavel/publicavel. Recebe somente Pull Request de `develop`.
- `develop`: branch de integracao. Recebe somente Pull Requests de branches de trabalho.

## Fluxo obrigatorio

1. Atualize `develop`.
2. Crie `feature/*`, `fix/*`, `chore/*`, `docs/*`, `test/*` ou `hotfix/*`.
3. Nao desenvolva diretamente em `develop` ou `main`.
4. Rode `scripts/pre_pr_check.sh`.
5. Abra PR para `develop`.
6. Aguarde `branch-policy`, `repository-audit` e `godot-tests`.
7. Resolva todas as threads abertas.
8. Review humano e opcional, mas recomendado para mudancas relevantes.
9. Use Squash para entrar em `develop`.
10. Releases usam PR `develop -> main` e Merge Commit.

## Politica de Pull Request

Pull Request continua obrigatorio.

Aprovacao humana nao e requisito tecnico obrigatorio.
O mantenedor responsavel pode mergear o proprio PR depois que todos os gates
automaticos obrigatorios estiverem verdes.

Reviews de outros integrantes continuam permitidos e recomendados.

Force push e exclusao de `develop` e `main` permanecem bloqueados.

## Gates automaticos

- `branch-policy`
- `repository-audit`
- `godot-tests`

## Genealogia

`develop` usa historico linear e checks strict.

`main` usa merge commit de release e
`strict_required_status_checks_policy=false`, evitando merges artificiais
`main -> develop`.

## Arquivos proibidos

Nao versionar `.godot/`, logs, caches Python, temporarios,
patches operacionais ou builds locais nao solicitados.
