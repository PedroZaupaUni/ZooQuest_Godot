# Estado atual da versao funcional

## Escopo implementado

O ZooQuest esta organizado como uma jornada 2D continua, ainda que tecnicamente utilize cenas especializadas do Godot. As mensagens, transformacoes e mini-games sao carregados por `core/main.gd`, que atua como controlador do fluxo.

### Funcionalidades presentes

- menu inicial e instrucoes;
- introducao narrativa em paginas;
- transformacao humano -> sapo -> humano;
- Sapo Matematico com selecao e salto para vitorias-regias;
- transformacao humano -> passaro -> humano;
- Passaro Logico com movimento entre tres passagens e progressao continua;
- transformacao humano -> minhoca -> humano;
- Minhoca das Escolhas com movimento livre e coleta de frutas-resposta;
- nove desafios educativos;
- feedback imediato de acerto e erro;
- explicacao apos cada escolha incorreta;
- pontuacao global;
- contagem de acertos e tentativas incorretas;
- encerramento com avaliacao simples e replay;
- recursos locais, sem API, backend ou banco de dados.

## Limites honestos desta entrega

- A arte e procedural/provisoria, criada localmente para garantir independência de assets externos.
- Nao ha build exportado ou publicacao; o foco desta entrega e o projeto de jogo no Godot.
- A validacao automatizada realizada fora do editor e estrutural. O roteiro manual deve ser executado no Godot para confirmar o comportamento na maquina de apresentacao.
- Os textos educativos podem passar por revisao pedagogica futura.
