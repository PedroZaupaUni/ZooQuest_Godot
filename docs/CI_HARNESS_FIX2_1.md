# ZooQuest — Governance FIX2.1 / CI Harness Remediation

## Problemas corrigidos

1. `git diff --check` falhava por trailing whitespace no template de PR e no artefato histórico `.patch`.
2. Os testes eram executados com `--script`, fora do runtime normal do projeto, e os autoloads (`GameState`, `QuestionBank`, `FlowRepository`, `AudioManager`) não estavam disponíveis da mesma forma que no jogo.
3. O smoke test podia imprimir `PASS` mesmo quando o Godot registrava `Compile Error`.
4. O bootstrap consultava os checks cedo demais e podia receber `no checks reported` antes da criação do workflow run.

## Solução

- Test runners convertidos para cenas `.tscn` executadas dentro do projeto.
- Smoke valida autoloads, scripts e cenas.
- Flow cobre o fluxo completo, retorno humano, Bird/Worm, replay e retorno ao menu.
- CI falha se os logs contiverem erros críticos do Godot.
- `actions/checkout` atualizado para v6 pinado em SHA completo.
- Artefato operacional `ZooQuest_FIX1_RUNTIME_HARDENING.patch` removido da baseline.
- Aplicador FIX2.1 espera o workflow run correspondente ao HEAD real antes de prosseguir.
