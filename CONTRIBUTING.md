# Contribuindo com o ZooQuest

## Branches canonicas

- `main`: baseline estavel/publicavel. Recebe somente Pull Request vindo de `develop`.
- `develop`: integracao do time. Recebe somente Pull Requests de branches curtas.

## Fluxo obrigatorio

1. `git switch develop && git pull --ff-only origin develop`.
2. Crie `feature/...`, `fix/...`, `chore/...`, `docs/...`, `test/...` ou `hotfix/...`.
3. Implemente a mudanca sem editar diretamente `develop` ou `main`.
4. Rode `scripts/pre_pr_check.sh`.
5. Push da branch e PR para `develop`.
6. Aguarde `branch-policy`, `repository-audit`, `godot-tests`, review e resolucao das threads.
7. Merge por Squash em `develop`.
8. Quando `develop` estiver homologada para release, abra PR `develop -> main`.
9. Repita CI/review e use **merge commit** em `main` para registrar o release.
10. Nao sincronize `main -> develop` apenas para satisfazer o release. O PR de release e testado no merge result pelo GitHub Actions e a `main` nao exige branch estritamente atualizada.

## Por que o status check da main nao usa modo strict

A `main` cria um merge commit de release cujo pai inclui `develop`. Depois desse release, novos commits continuam em `develop` a partir da propria linha de integracao. Exigir que `develop` contenha o merge commit anterior da `main` forçaria merges `main -> develop`, quebrando o historico linear da branch de integracao. Por isso a `main` exige todos os checks, mas `strict_required_status_checks_policy=false`; a `develop` permanece strict e linear.

## Politica de Pull Request

- 1 aprovacao obrigatoria.
- O ultimo push precisa ser aprovado por outra pessoa.
- Aprovacoes antigas sao descartadas apos novos commits revisaveis.
- Todas as conversas precisam estar resolvidas.
- `branch-policy`, `repository-audit` e `godot-tests` precisam estar verdes.
- Force push e exclusao de `develop`/`main` sao bloqueados.
- `main` aceita PR somente de `develop`.
- `develop` aceita PR somente de branches de trabalho permitidas.
- `develop`: Squash merge e historico linear.
- `main`: merge commit somente de `develop`.

## Mudancas de gameplay

PRs de gameplay devem testar caminho de acerto, erro/retry, entrada/saida da fase, navegacao e ausencia de erros no Debugger. Mudancas visuais devem incluir print ou video curto.

## Arquivos proibidos

Nao versionar `.godot/`, logs de runtime, caches Python, temporarios, patches operacionais ou builds locais nao solicitados.
