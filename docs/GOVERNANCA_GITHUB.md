# Governança do repositório

## Fluxo de branches

```text
feature/* | fix/* | chore/* | docs/* | test/* | hotfix/*
                         -> develop
                         -> main
```

`develop` é a branch de integração. `main` representa a versão estável.

## Pull Requests

- alterações de trabalho entram em `develop` por Pull Request;
- `develop` entra em `main` por Pull Request de release;
- push direto para `develop` e `main` é bloqueado pelo fluxo local e pelas regras remotas;
- review humano é opcional;
- conversas de review abertas precisam ser resolvidas;
- os checks obrigatórios devem estar verdes.

## Checks obrigatórios

- `branch-policy`;
- `repository-audit`;
- `godot-tests`.

## Estratégia de merge

`develop` aceita **Squash Merge** e mantém histórico linear.

`main` aceita **Merge Commit** vindo de `develop`. O merge commit registra formalmente cada publicação sem obrigar a branch de integração a incorporar o commit de release de volta.

Por esse motivo, os checks de `develop` usam política estrita de atualização da base, enquanto os checks de `main` usam `strict_required_status_checks_policy=false`.

## Proteções

As duas branches canônicas bloqueiam:

- exclusão;
- force push;
- merge sem Pull Request;
- merge sem os checks obrigatórios;
- merge com conversas de review não resolvidas.

## Permissões da CI

O workflow usa `contents: read`. A Action externa utilizada no checkout é fixada por SHA completo. O binário Godot 4.7.2 também é validado por SHA-256 antes da execução.

## CODEOWNERS

`@PedroZaupaUni` mantém ownership geral e das áreas de núcleo, automação e documentação. `@danielyassuo` também está associado às áreas de personagens, mini-games e ícones, onde há contribuição técnica registrada.
