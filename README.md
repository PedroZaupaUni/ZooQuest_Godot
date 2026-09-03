# ZooQuest: A Jornada do Aprendizado

Versao funcional completa de desenvolvimento do jogo educativo 2D produzido no Godot.

## Estado desta entrega

`VERSAO_FUNCIONAL_LOCAL - 3 MINI-GAMES - FLUXO COMPLETO`

O projeto implementa o fluxo jogavel do inicio ao fim:

1. menu inicial;
2. introducao narrativa;
3. transformacao em sapo;
4. mini-game Sapo Matematico;
5. retorno a forma humana;
6. transformacao em passaro;
7. mini-game Passaro Logico;
8. retorno a forma humana;
9. transformacao em minhoca;
10. mini-game Minhoca das Escolhas;
11. retorno a forma humana;
12. encerramento, pontuacao e opcao de jogar novamente.

## Abrir e executar

1. Instale Godot 4.x Standard (o projeto foi preparado para Godot 4.7.2 e usa apenas APIs estaveis da familia 4.x).
2. No Gerenciador de Projetos, clique em **Importar**.
3. Selecione este arquivo `project.godot`.
4. Abra o projeto e pressione **F6/F5**; para a jornada completa, use **F5**.

Nao e necessario instalar plugin, API, banco de dados ou dependencia externa.

## Controles

### Geral
- `ENTER` ou `ESPACO`: continuar mensagens e transformacoes.
- `MENU`: retorna ao menu principal.
- `1`, `2`, `3`: atalho de escolha nas fases.

### Sapo Matematico
- `ESQUERDA/DIREITA` ou `A/D`: selecionar vitoria-regia.
- `ESPACO`: pular para a alternativa selecionada.
- Tambem e possivel clicar em uma vitoria-regia.

### Passaro Logico
- `CIMA/BAIXO` ou `W/S`: mudar de passagem.
- Escolha antes que a barreira alcance o passaro.

### Minhoca das Escolhas
- Setas ou `WASD`: movimentar.
- Encoste ou clique na fruta-resposta correta.

## Regras implementadas

- 3 perguntas em cada fase, totalizando 9 desafios.
- Cada acerto vale 10 pontos; pontuacao maxima: 90.
- Resposta incorreta nao remove pontos: registra a tentativa, explica a resposta e repete o desafio.
- A jornada volta a forma humana depois de cada mini-game.
- O jogo pode ser reiniciado a partir da tela final.

## Estrutura

```text
core/           fluxo global, estado e audio
ui/             menu, narrativa, transformacoes, HUD e encerramento
characters/     controladores visuais dos tres animais
minigames/      sapo, passaro e minhoca
data/           perguntas e fluxo narrativo em JSON
assets/         sons e recursos locais
docs/           fontes, diagramas, planejamento e relatorio
scripts/        validador estatico do repositorio
tests/manual/   roteiro de testes funcionais no Godot
```

## Validacao local sem abrir o editor

```bash
python3 scripts/validate_repository.py
```

A validacao confirma estrutura, referencias `res://`, JSON, perguntas, fluxo, cenas, scripts e WAVs. A validacao funcional final deve ser executada no editor Godot usando o roteiro em `tests/manual/ROTEIRO_TESTE_FUNCIONAL.md`.

## Documentacao

Comece por `CONTINUE_AQUI.md`. Os documentos originais utilizados na reconstrucao estao preservados em `docs/fontes/`.
