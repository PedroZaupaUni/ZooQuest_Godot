# Status do projeto

## Versão funcional

O ZooQuest possui uma jornada jogável completa do menu ao encerramento, com três mini-games e nove desafios educacionais.

Funcionalidades disponíveis:

- menu inicial e instruções;
- introdução narrativa;
- transformação em sapo, pássaro e minhoca;
- retorno à forma humana após cada mini-game;
- Sapo Matemático com seleção e salto para vitórias-régias;
- Pássaro Lógico com escolha entre faixas e interação por mouse;
- Minhoca das Escolhas com movimento livre, colisão e seleção por mouse;
- feedback imediato de acerto e erro;
- explicação após tentativa incorreta;
- pontuação global e contagem de resultados;
- encerramento, jogar novamente e retorno ao menu.

## Dados e infraestrutura

- perguntas e narrativa são armazenadas localmente;
- não há API, banco de dados, autenticação ou backend;
- o projeto é executado no Godot 4.7.2;
- o repositório não versiona builds exportados.

## Qualidade

A CI cobre `develop`, `main` e Pull Requests destinados a essas branches. Os checks obrigatórios são:

- `branch-policy`;
- `repository-audit`;
- `godot-tests`.

Os testes Godot verificam importação de recursos, carregamento das cenas, fluxo completo da jornada, reinício, retorno ao menu e encerramento sem erros ou vazamentos reportados pelo motor.

O roteiro manual em `tests/manual/ROTEIRO_TESTE_FUNCIONAL.md` complementa a automação e deve ser usado antes de apresentações ou entregas acadêmicas.

## Limites atuais

- não há menu de pausa dedicado;
- acessibilidade ainda pode ser ampliada;
- conteúdo educacional pode receber revisão pedagógica adicional;
- arte, animações e áudio podem receber refinamento visual e sonoro sem alterar o núcleo da mecânica.
