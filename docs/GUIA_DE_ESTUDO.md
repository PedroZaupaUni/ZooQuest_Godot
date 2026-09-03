# Guia de estudo do código

## Objetivo

Entender como o ZooQuest foi separado em partes pequenas, para que cada melhoria seja feita sem misturar fluxo, conteúdo, interface e mecânica.

## 1. Comece pelo fluxo

Abra `core/main.gd`.

Ele não implementa física, perguntas ou desenho dos animais. Sua função é ler `data/story_flow.json`, montar a etapa correta e escutar o sinal de conclusão.

Analogia: `Main` é o diretor da excursão. Ele diz qual atividade começa, mas não resolve a atividade pelo jogador.

## 2. Depois veja o estado global

Abra `core/game_state.gd`.

Ele guarda:

- pontos;
- total de acertos;
- total de tentativas incorretas;
- etapa atual.

O mini-game informa um acerto; o estado global atualiza a pontuação e emite um sinal para o HUD.

## 3. Conteúdo não fica preso ao código

Abra `data/questions.json`.

Cada pergunta possui:

```json
{
  "id": "FROG_MATH_001",
  "category": "matematica",
  "difficulty": 1,
  "question": "Quanto e 4 + 3?",
  "options": ["6", "7", "8"],
  "correct_index": 1,
  "explanation": "4 + 3 e igual a 7."
}
```

`correct_index` começa em zero. Portanto:

- `0` = primeira alternativa;
- `1` = segunda alternativa;
- `2` = terceira alternativa.

## 4. Observe o contrato comum das fases

As três cenas em `minigames/` emitem os mesmos sinais:

```gdscript
signal completed
signal menu_requested
```

Isso permite que `Main` integre fases diferentes da mesma maneira.

## 5. Estude uma fase por vez

### Sapo

Leia nesta ordem:

1. `minigames/frog/frog_minigame.gd`;
2. `characters/frog/frog_player.gd`;
3. `minigames/frog/lily_pad.gd`.

A fase escolhe a pergunta, a vitória-régia guarda uma alternativa e o jogador executa a animação de salto.

### Pássaro

Leia:

1. `minigames/bird/bird_minigame.gd`;
2. `characters/bird/bird_player.gd`;
3. `minigames/bird/answer_gate.gd`.

A barreira anda para a esquerda; o pássaro muda entre três faixas. Quando a barreira chega ao ponto de validação, a faixa atual é comparada à resposta correta.

### Minhoca

Leia:

1. `minigames/worm/worm_minigame.gd`;
2. `characters/worm/worm_player.gd`;
3. `minigames/worm/fruit_answer.gd`.

A minhoca usa `CharacterBody2D`. As frutas são `Area2D`; quando detectam o corpo do jogador, emitem a alternativa escolhida.

## 6. Exercício curto

Adicione uma quarta pergunta à fase do sapo em `data/questions.json`.

Antes de executar, responda:

1. Qual será o `id` único?
2. Quais serão as três alternativas?
3. Qual índice representa a resposta correta?
4. Que explicação ajudará a criança a compreender a resposta?

Depois execute:

```bash
python3 scripts/validate_repository.py
```

O validador atual exige exatamente três perguntas por fase. Como parte do exercício, altere o contrato `questions_count` para aceitar `len(phase_questions) >= 3` e explique por que essa mudança é necessária.

## Erros comuns

- Alterar `correct_index` como se a contagem começasse em 1.
- Fazer o mini-game carregar diretamente a próxima fase.
- Colocar pontuação dentro de cada fase e perder o valor ao trocar de cena.
- Duplicar uma pergunta com o mesmo `id`.
- Declarar a fase pronta sem testar a resposta incorreta e o reinício.
