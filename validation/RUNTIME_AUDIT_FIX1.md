# ZooQuest - Auditoria Runtime FIX1

Data: 2026-09-03

## Evidencia recebida

Execucao real no Godot 4.7.2 confirmou:

- menu inicial renderizado;
- Fase 1 - Sapo Matematico iniciada;
- pontuacao atualizada apos acertos;
- feedback de erro exibido e tentativa retomada;
- conclusao da fase do sapo;
- transicao de retorno a forma humana;
- em uma execucao anterior, a fase do passaro chegou a iniciar e o erro ocorreu ao final;
- em nova execucao, o erro ocorreu ao acionar CONTINUAR antes da fase do passaro.

## Causa raiz confirmada

`ui/transformation_screen.gd` chamava `_on_continue_pressed()` antes de
`get_viewport().set_input_as_handled()`.

`_on_continue_pressed()` emite `finished`. O `core/main.gd` recebia o sinal de forma
sincrona e trocava imediatamente o stage atual. Quando o callback retornava para a tela
de transformacao, ela ja estava fora do SceneTree; por isso `get_viewport()` retornava
null e ocorria:

`Cannot call method 'set_input_as_handled' on a null value.`

A mesma classe de risco existia em `ui/narrative_screen.gd`.

## Correcoes FIX1

1. O evento de teclado agora e marcado como tratado antes de qualquer sinal que possa
   trocar de stage.
2. O acesso ao viewport agora possui guarda contra null.
3. Todos os sinais de navegacao conectados em `core/main.gd` usam `CONNECT_DEFERRED`,
   evitando mutacao reentrante da arvore durante callbacks de input/UI.
4. Frog, Bird e Worm receberam guardas `is_inside_tree()` depois de awaits para evitar
   retomada de coroutine em stage removido pelo botao MENU.
5. Foi criado `scripts/validate_runtime_patterns.py` para impedir regressao dessa classe
   de erro.
6. Foi criado `tests/flow_transition_test.gd` para percorrer headlessly as transicoes
   completas quando executado com Godot.

## Estado da validacao

- validacao estatica do repositorio: PASS;
- validacao de padroes de runtime/lifecycle: PASS;
- execucao grafica completa apos FIX1: PENDENTE de reteste no ambiente local do aluno;
- portanto o jogo NAO deve ser declarado totalmente operacional ate concluir o roteiro
  manual e o teste headless com Godot.
