## Objetivo

Descreva em 2-5 linhas o que este PR muda e por que a mudanca e necessaria.

## Escopo

- [ ] Gameplay / mini-game
- [ ] Core / fluxo / estado
- [ ] UI / narrativa
- [ ] Dados / perguntas
- [ ] Testes / QA
- [ ] Documentacao
- [ ] CI / governanca

## Como validar

Liste os passos exatos para reproduzir e testar a mudanca.

1.
2.
3.

## Evidencias

- Prints/video quando houver mudanca visual ou de gameplay:
- Logs/resultado dos testes quando aplicavel:

## Checklist obrigatorio

- [ ] Minha branch esta atualizada com `main`.
- [ ] Nao fiz push direto em `main`.
- [ ] `python3 scripts/validate_repository.py` passa.
- [ ] `python3 scripts/validate_runtime_patterns.py` passa.
- [ ] `python3 scripts/audit_repository.py` passa.
- [ ] Testei o caminho de sucesso e o caminho de erro/retry afetados pela mudanca.
- [ ] Nao adicionei `.godot/`, logs locais, temporarios ou artefatos de execucao.
- [ ] Atualizei documentacao/dados se o comportamento mudou.
- [ ] Revisei o diff do PR antes de solicitar review.

## Risco e rollback

Explique brevemente o que pode quebrar e como reverter esta mudanca.
