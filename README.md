# ZooQuest: A Jornada do Aprendizado

[![ZooQuest CI](https://github.com/PedroZaupaUni/ZooQuest_Godot/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/PedroZaupaUni/ZooQuest_Godot/actions/workflows/ci.yml)

ZooQuest é um jogo educativo 2D desenvolvido em **Godot 4.7.2**. A experiência acompanha uma excursão a um zoológico e combina narrativa, transformação de personagem e três mini-games voltados a matemática, raciocínio lógico e tomada de decisão.

O projeto é acadêmico, funciona localmente e não depende de API, banco de dados, autenticação ou backend.

## Funcionalidades

- jornada contínua do menu ao encerramento;
- três mini-games: Sapo Matemático, Pássaro Lógico e Minhoca das Escolhas;
- nove desafios educativos, três por fase;
- pontuação de 10 pontos por acerto, com máximo de 90 pontos;
- feedback de acerto e erro, com nova tentativa após resposta incorreta;
- retorno à forma humana entre as fases;
- controles por teclado e interações por mouse nas mecânicas compatíveis;
- tela final com pontuação, reinício da jornada e retorno ao menu;
- testes automatizados de inicialização, fluxo completo e encerramento limpo.

## Fluxo do jogo

```text
Menu
  -> Introdução
  -> Transformação em sapo
  -> Sapo Matemático
  -> Retorno humano
  -> Transformação em pássaro
  -> Pássaro Lógico
  -> Retorno humano
  -> Transformação em minhoca
  -> Minhoca das Escolhas
  -> Retorno humano
  -> Encerramento
  -> Jogar novamente ou voltar ao menu
```

## Controles

| Contexto | Controles |
|---|---|
| Narrativa e transformações | `Enter` ou `Espaço` para continuar |
| Sapo Matemático | `A/D` ou setas para selecionar; `Espaço` para saltar; clique na vitória-régia |
| Pássaro Lógico | `W/S` ou setas para mudar de faixa; mouse para selecionar uma faixa |
| Minhoca das Escolhas | `WASD` ou setas para mover; contato ou clique na fruta-resposta |

## Executar localmente

1. Instale o Godot 4.7.2 Standard.
2. No Gerenciador de Projetos do Godot, selecione **Importar**.
3. Escolha o arquivo `project.godot` da raiz do repositório.
4. Pressione **F5** para iniciar a jornada completa.

Não há dependências adicionais de aplicação.

## Estrutura do repositório

```text
assets/        recursos de áudio e ícones
characters/    controladores dos personagens jogáveis
core/          fluxo global, estado e áudio
data/          perguntas e sequência narrativa
docs/          documentação técnica, acadêmica e materiais de referência
minigames/     implementação das três fases
scripts/       validações e utilitários do projeto
shared/        componentes reutilizáveis
tests/         testes automatizados e roteiro manual
ui/            menu, HUD, narrativa, transformações e encerramento
```

## Qualidade e testes

Para executar as validações estáticas:

```bash
./scripts/run_validation.sh
```

Para executar os testes no Godot:

```bash
GODOT_BIN=/caminho/para/Godot_v4.7.2-stable_linux.x86_64 ./scripts/run_godot_smoke.sh
```

A integração contínua executa automaticamente:

- política de branches (`branch-policy`);
- auditoria do repositório (`repository-audit`);
- importação no Godot 4.7.2;
- smoke test;
- regressão do fluxo completo;
- teste de inicialização da cena principal;
- auditoria de erros e vazamentos reportados pelo motor.

Detalhes: [Qualidade e testes](docs/QUALIDADE_E_TESTES.md).

## Desenvolvimento

O fluxo de contribuição é:

```text
feature/* | fix/* | chore/* | docs/* | test/* | hotfix/*
                         -> develop
                         -> main
```

As regras para branches, Pull Requests e validação estão em [CONTRIBUTING.md](CONTRIBUTING.md).

## Documentação

A documentação do projeto está organizada em [docs/README.md](docs/README.md). Os documentos acadêmicos originais e modelos editáveis estão preservados em `docs/referencias/`.

## Links

- Repositório: https://github.com/PedroZaupaUni/ZooQuest_Godot
- Portfólio: https://zooquest-unifil-portfolio.netlify.app
