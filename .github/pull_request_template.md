## Objetivo

Descreva em 2-5 linhas o que este PR muda e por que a mudanca e necessaria.

## Fluxo da branch

- Trabalho normal: `feature/* | fix/* | chore/* | docs/* | test/* | hotfix/* -> develop`.
- Release: `develop -> main`.

## Escopo

- [ ] Gameplay / mini-game
- [ ] Core / fluxo / estado
- [ ] UI / narrativa
- [ ] Dados / perguntas
- [ ] Testes / QA
- [ ] Documentacao
- [ ] CI / governanca

## Como validar

1.
2.
3.

## Evidencias

- Prints/video quando houver mudanca visual ou de gameplay:
- Logs/resultado dos testes quando aplicavel:

## Checklist obrigatorio

- [ ] Minha branch nasceu da `develop` atualizada, ou este PR e `develop -> main`.
- [ ] Nao fiz push direto em `develop` ou `main`.
- [ ] `scripts/pre_pr_check.sh` passa quando aplicavel.
- [ ] Testei caminho de sucesso e erro/retry afetados pela mudanca.
- [ ] Nao adicionei `.godot/`, logs, caches, temporarios ou artefatos de execucao.
- [ ] Atualizei documentacao/dados quando o comportamento mudou.
- [ ] Revisei o diff antes do merge ou de solicitar review opcional.

## Risco e rollback

Explique brevemente o que pode quebrar e como reverter esta mudanca.
