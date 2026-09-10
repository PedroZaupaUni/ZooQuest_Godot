# Governanca GitHub - ZooQuest

## Fluxo canonico

`feature/* | fix/* | chore/* | docs/* | test/* | hotfix/* -> develop -> main`

`develop` e a branch de integracao. `main` e a baseline estavel/publicavel. Nenhuma recebe desenvolvimento direto.

## Gates obrigatorios

1. Pull Request.
2. Uma aprovacao.
3. Ultimo push aprovado por outra pessoa.
4. Reviews antigos descartados apos novos commits.
5. Todas as threads resolvidas.
6. `branch-policy` verde.
7. `repository-audit` verde.
8. `godot-tests` verde.
9. Squash merge em `develop`; merge commit em `main`.
10. Sem force push ou exclusao das branches protegidas.

## Branch policy

- PR para `main`: head exatamente `develop`.
- PR para `develop`: head `feature/*`, `fix/*`, `chore/*`, `docs/*`, `test/*` ou `hotfix/*`.
- PR `main -> develop` e proibido como rotina.

## Status checks e genealogia

`develop` usa status checks strict e historico linear. `main` exige os mesmos checks, mas nao exige que o head esteja estritamente atualizado com a base (`strict_required_status_checks_policy=false`). Isso e intencional: cada release gera merge commit em `main`; forcar `develop` a absorver esse merge commit antes do release seguinte criaria merges `main -> develop` e destruiria o historico linear de integracao. O workflow de `pull_request` testa o merge result antes do release.

## CI

O workflow executa em PR/push de `develop` e `main`. `repository-audit` valida contratos estaticos; `godot-tests` usa Godot 4.7.2 verificado por SHA-256 para import, smoke, fluxo completo e startup limpo; `branch-policy` valida a direcao do Git flow.

## CODEOWNERS

`@PedroZaupaUni` permanece como CODEOWNER geral ate a equipe definir ownership por modulo. A aprovacao obrigatoria deve vir de outra pessoa quando o autor fez o ultimo push.
