# Roteiro do vídeo de demonstração - máximo 7 minutos

O vídeo precisa ser gravado pelo grupo porque a atividade exige participação dos integrantes com câmera aberta. Este roteiro organiza a gravação sem substituir essa participação.

| Tempo | Conteúdo | Evidência na tela |
|---:|---|---|
| 0:00-0:35 | Apresentação do ZooQuest, público infantil e ODS 4 | Capa/portfólio e menu do jogo |
| 0:35-1:05 | Narrativa, objetivo e ciclo pergunta-escolha-feedback | Diagrama de fluxo e ciclo de gameplay |
| 1:05-2:20 | Demonstração do Sapo Matemático | Uma resposta errada e uma correta |
| 2:20-3:30 | Demonstração do Pássaro Lógico | Mudança de faixa, colisão e acerto |
| 3:30-4:40 | Demonstração da Minhoca das Escolhas | Movimento, fruta errada e correta |
| 4:40-5:20 | Encerramento, pontuação e jogar novamente | Tela final e retorno ao menu |
| 5:20-6:05 | Decisões de design e arquitetura | Árvore de arquivos, `story_flow.json` e `questions.json` |
| 6:05-6:45 | Participação dos integrantes e responsabilidades | Cada integrante fala brevemente com câmera aberta |
| 6:45-7:00 | Conclusão | Repositório e relatório PDF |

## Falas mínimas sugeridas

### Abertura

"O ZooQuest é um jogo educativo 2D ambientado em um zoológico. A criança aprende matemática, raciocínio lógico e responsabilidade por meio de três mini-games conectados por uma jornada contínua."

### Decisão de design

"Cada animal possui uma mecânica própria, mas todas seguem o mesmo ciclo: o jogo mostra uma pergunta, o jogador escolhe uma alternativa integrada ao cenário, o sistema valida, oferece feedback e permite avançar ou tentar novamente."

### Arquitetura

"O fluxo global é controlado pelo arquivo `core/main.gd`. As perguntas e a narrativa foram separadas em JSON, e cada mini-game emite um sinal de conclusão para não depender diretamente da próxima fase."

### Fechamento

"A versão demonstrada possui navegação completa, nove perguntas, pontuação, feedback, retorno à forma humana após cada fase e possibilidade de jogar novamente."

## Antes de gravar

- concluir os 30 testes funcionais;
- fechar o painel do Debugger sem erros vermelhos;
- ensaiar uma partida com respostas previamente escolhidas;
- confirmar microfone e câmera de todos;
- manter o vídeo abaixo de 7 minutos;
- publicar como não listado e enviar o link individualmente no Classroom.
