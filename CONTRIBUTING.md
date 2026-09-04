# Contribuindo com o ZooQuest

## Regra principal

`main` e a baseline estavel. Ninguem trabalha diretamente nela.

Fluxo obrigatorio:

1. Atualize `main`.
2. Crie uma branch curta (`feature/...`, `fix/...`, `docs/...`, `test/...`, `chore/...`).
3. Implemente uma mudanca de escopo pequeno.
4. Rode `scripts/pre_pr_check.sh`.
5. Faça push da branch.
6. Abra Pull Request usando o template.
7. Aguarde CI e review.
8. Resolva todas as conversas.
9. Merge somente por **Squash**.

## Politica de Pull Request

- 1 aprovacao obrigatoria.
- O ultimo push precisa ser aprovado por outra pessoa.
- Aprovacoes antigas sao descartadas quando novos commits reviewable sao enviados.
- Todas as conversas precisam estar resolvidas.
- `repository-audit` e `godot-tests` precisam estar verdes.
- Force push e exclusao de `main` sao bloqueados.
- `main` deve manter historico linear.
- CODEOWNERS solicita automaticamente o lead tecnico.

## Mudancas de gameplay

PRs de gameplay devem testar:

- caminho de acerto;
- caminho de erro/retry;
- entrada e saida da fase;
- navegacao para a proxima etapa;
- ausencia de erros no Debugger.

Mudancas visuais devem incluir print ou video curto no PR.

## Arquivos proibidos no Git

Nao versionar:

- `.godot/`;
- logs de runtime;
- `validation/FIX1_<timestamp>/`;
- arquivos temporarios;
- builds locais nao solicitados.

## Ownership

Enquanto os demais handles ainda nao estiverem documentados, `@PedroZaupaUni` e solicitado como CODEOWNER geral. Isso nao substitui a aprovacao obrigatoria de outra pessoa quando Pedro for o autor do ultimo push.
