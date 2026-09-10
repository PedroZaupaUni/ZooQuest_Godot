# Arquitetura do ZooQuest

## Visão geral

A aplicação utiliza uma cena principal persistente e substitui apenas a etapa ativa da jornada.

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

`core/main.gd` coordena a sequência definida em `data/story_flow.json`. As cenas de gameplay não escolhem diretamente a próxima etapa; elas comunicam conclusão por sinais e o controlador global decide a transição.

## Autoloads

| Autoload | Responsabilidade |
|---|---|
| `GameState` | Pontuação, acertos, erros e fase atual |
| `QuestionBank` | Leitura e acesso às perguntas de `data/questions.json` |
| `FlowRepository` | Leitura da sequência de `data/story_flow.json` |
| `AudioManager` | Reprodução e gerenciamento dos efeitos sonoros |

## Organização por domínio

- `core/`: coordenação global e estado compartilhado;
- `data/`: conteúdo educativo e sequência narrativa;
- `ui/`: telas gerais, HUD e componentes de navegação;
- `characters/`: movimento e representação dos personagens;
- `minigames/`: regras específicas de cada fase;
- `shared/`: componentes reutilizáveis;
- `tests/`: testes automatizados e roteiro de validação manual.

## Contrato das fases

Cada mini-game expõe os sinais usados pelo controlador principal:

```gdscript
signal completed
signal menu_requested
```

`completed` informa que as três perguntas da fase foram concluídas. `menu_requested` devolve o controle ao menu principal.

## Dados

As perguntas ficam fora dos scripts em `data/questions.json`. Cada item possui identificador, categoria, dificuldade, enunciado, três alternativas, índice da resposta correta e explicação.

A ordem narrativa fica em `data/story_flow.json`, que contém as transformações, retornos à forma humana, telas narrativas e fases jogáveis.

## Ciclo de uma pergunta

```text
carregar pergunta
    -> apresentar alternativas no cenário
    -> receber escolha
    -> validar resposta
       -> correta: registrar pontos e avançar
       -> incorreta: registrar tentativa, explicar e repetir
```

## Segurança de lifecycle

As trocas de etapa usam conexões diferidas para evitar alteração reentrante da árvore de cenas durante callbacks de interface. Rotinas assíncronas verificam se a cena ainda pertence à `SceneTree` antes de continuar após `await`.

Os testes automatizados também encerram cenas e efeitos de áudio de forma determinística para detectar vazamentos de objetos ou recursos no Godot.
