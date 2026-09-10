# Guia do código

## Entrada da aplicação

A cena principal é `core/main.tscn`, controlada por `core/main.gd`. Ela mantém o `StageHost` e instancia a etapa correspondente ao fluxo atual.

## Estado global

`core/game_state.gd` mantém:

- pontuação;
- quantidade de acertos;
- quantidade de tentativas incorretas;
- fase atual.

As telas consultam esse estado em vez de duplicar pontuação localmente.

## Perguntas

`data/questions.json` organiza o conteúdo por fase:

```json
{
  "frog": [],
  "bird": [],
  "worm": []
}
```

Cada pergunta possui três alternativas. `correct_index` usa índice iniciado em zero: `0`, `1` ou `2`.

`data/question_bank.gd` é responsável por carregar e fornecer esse conteúdo às fases.

## Fluxo narrativo

`data/story_flow.json` define a sequência da jornada. `data/flow_repository.gd` lê o arquivo e `core/main.gd` transforma cada item em uma cena ativa.

## Sapo Matemático

Arquivos principais:

- `minigames/frog/frog_minigame.gd`;
- `characters/frog/frog_player.gd`;
- `minigames/frog/lily_pad.gd`.

A vitória-régia representa uma alternativa e a fase valida a opção selecionada após a interação do personagem.

## Pássaro Lógico

Arquivos principais:

- `minigames/bird/bird_minigame.gd`;
- `characters/bird/bird_player.gd`;
- `minigames/bird/answer_gate.gd`.

O jogador escolhe uma faixa enquanto a barreira avança. A faixa selecionada é comparada à alternativa correta no ponto de validação.

## Minhoca das Escolhas

Arquivos principais:

- `minigames/worm/worm_minigame.gd`;
- `characters/worm/worm_player.gd`;
- `minigames/worm/fruit_answer.gd`.

A minhoca se movimenta pelo cenário e as frutas representam as alternativas. A seleção pode ocorrer por contato ou mouse.

## Interface

- `ui/main_menu.gd`: menu e instruções;
- `ui/narrative_screen.gd`: mensagens narrativas;
- `ui/transformation_screen.gd`: transições de personagem;
- `ui/hud.gd`: pergunta, alternativas e pontuação;
- `ui/ending_screen.gd`: resultado e opções finais.

## Antes de alterar o código

Use `CONTRIBUTING.md` para o fluxo de branches e execute `./scripts/pre_pr_check.sh` antes de abrir um Pull Request.
