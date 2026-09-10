# Contribuindo com o ZooQuest

## Branches

- `develop`: branch de integração do time.
- `main`: versão estável e publicável.

O desenvolvimento não deve ser feito diretamente em nenhuma das duas branches.

## Fluxo de trabalho

Atualize a `develop` antes de iniciar uma tarefa:

```bash
git switch develop
git pull --ff-only origin develop
```

Crie uma branch curta e descritiva:

```bash
git switch -c feature/nome-da-funcionalidade
```

Prefixos aceitos:

- `feature/`: nova funcionalidade;
- `fix/`: correção de defeito;
- `chore/`: manutenção técnica;
- `docs/`: documentação;
- `test/`: testes;
- `hotfix/`: correção urgente preparada para o fluxo normal de integração.

Antes do push, execute:

```bash
./scripts/pre_pr_check.sh
```

Depois publique a branch e abra o Pull Request para `develop`:

```bash
git push -u origin HEAD
gh pr create --base develop --fill
```

## Integração

Pull Requests para `develop` devem passar por:

- `branch-policy`;
- `repository-audit`;
- `godot-tests`;
- resolução de todas as conversas de review abertas.

O merge em `develop` é feito por **Squash**.

Quando a `develop` estiver pronta para publicação, o release é feito por Pull Request `develop -> main`. O merge em `main` é feito por **Merge Commit**, preservando a genealogia do Git flow.

## Review

Review humano é opcional. O mantenedor pode concluir o próprio Pull Request depois que os checks obrigatórios estiverem verdes e as conversas abertas estiverem resolvidas.

Para alterações relevantes de gameplay, arquitetura ou dados educacionais, revisão por outro integrante é recomendada.

## Commits

Prefira mensagens curtas e objetivas no formato:

```text
feat: adiciona ...
fix: corrige ...
docs: atualiza ...
test: cobre ...
chore: ajusta ...
```

## Requisitos para alterações de gameplay

Valide, quando aplicável:

- caminho de acerto;
- caminho de erro e nova tentativa;
- entrada e saída da fase;
- navegação para a próxima etapa;
- teclado e mouse;
- pontuação e reinício;
- ausência de erros no Debugger.

Mudanças visuais devem ser acompanhadas de captura de tela ou vídeo curto no Pull Request quando isso ajudar a revisão.

## Arquivos locais

Não versionar caches do Godot ou Python, logs, temporários, configurações pessoais de IDE ou builds locais não destinados ao repositório.
