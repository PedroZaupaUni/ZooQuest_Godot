# CONTINUE AQUI - ZooQuest

Este arquivo e o ponto de retomada do projeto.


## Hotfix runtime FIX1 - 2026-09-03

- Erro confirmado: `set_input_as_handled` em viewport nulo durante transicoes.
- Causa raiz corrigida em `ui/transformation_screen.gd` e `ui/narrative_screen.gd`.
- Navegacao endurecida com `CONNECT_DEFERRED` em `core/main.gd`.
- Teste de regressao: `scripts/validate_runtime_patterns.py`.
- Teste de fluxo Godot: `tests/flow_transition_test.gd`.
- Status: aguardando reteste completo no Godot antes de declarar runtime 100% operacional.

## Estado atual

- Projeto Godot 4.x estruturado e autossuficiente.
- Fluxo completo implementado do menu ao encerramento.
- Tres mini-games implementados: sapo, passaro e minhoca.
- Nove perguntas locais em `data/questions.json`.
- Pontuacao, feedback, repeticao de pergunta, transformacoes e replay implementados.
- Documentacao-fonte preservada em `docs/fontes/`.
- Validador estatico em `scripts/validate_repository.py`.

## Ordem de leitura

1. `README.md`
2. `docs/ESTADO_ATUAL.md`
3. `docs/ARQUITETURA.md`
4. `docs/PLANO_MESTRE.md`
5. `tests/manual/ROTEIRO_TESTE_FUNCIONAL.md`
6. `validation/VALIDATION_REPORT.json`

## Fonte de verdade

1. `data/questions.json` - conteudo educativo executado.
2. `data/story_flow.json` - sequencia real da jornada.
3. scripts e cenas Godot - comportamento implementado.
4. `docs/ESTADO_ATUAL.md` - estado declarado.
5. documentos em `docs/fontes/` - requisitos e historico.

## Proxima acao humana obrigatoria

Abrir `project.godot` no Godot, pressionar F5 e executar todos os casos do roteiro funcional. Registrar qualquer erro com:

- tela/etapa;
- acao realizada;
- resultado esperado;
- resultado observado;
- mensagem do Debugger;
- captura de tela.
