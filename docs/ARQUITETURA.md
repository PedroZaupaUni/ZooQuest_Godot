# Arquitetura do jogo

## Visao geral

```text
Main
└── StageHost
    ├── MainMenu
    ├── NarrativeScreen
    ├── TransformationScreen
    ├── FrogMinigame
    ├── BirdMinigame
    ├── WormMinigame
    └── EndingScreen
```

`Main` permanece ativo e substitui apenas a etapa dentro de `StageHost`. Para o jogador, a experiencia e uma jornada continua; tecnicamente, cada responsabilidade fica isolada em uma cena.

## Autoloads

- `GameState`: pontuacao e estatisticas globais.
- `QuestionBank`: carrega perguntas de `data/questions.json`.
- `FlowRepository`: carrega a sequencia de `data/story_flow.json`.
- `AudioManager`: reproduz efeitos sonoros locais.

## Contrato dos mini-games

Cada mini-game emite:

- `completed`: quando todas as tres perguntas foram concluidas;
- `menu_requested`: quando o jogador solicita retorno ao menu.

O mini-game nao decide qual etapa vem depois. Essa decisao pertence a `core/main.gd`.

## Separacao de responsabilidades

- Conteudo educativo e fluxo narrativo ficam em JSON.
- UI geral fica em `ui/`.
- Movimento/desenho dos animais fica em `characters/`.
- Regras especificas de cada fase ficam em `minigames/`.
- Estado global fica em `core/game_state.gd`.
