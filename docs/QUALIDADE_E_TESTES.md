# Qualidade e testes

## Validação estática

Execute na raiz do repositório:

```bash
./scripts/run_validation.sh
```

Esse comando valida:

- estrutura obrigatória do projeto;
- referências `res://`;
- contratos de perguntas e fluxo narrativo;
- estrutura mínima das cenas;
- arquivos WAV usados pelo jogo;
- padrões de lifecycle e navegação;
- documentação e nomenclatura do repositório;
- contratos de CI e proteção das branches;
- ausência de conflitos Git e arquivos temporários rastreados.

## Testes no Godot

Com Godot 4.7.2 disponível:

```bash
GODOT_BIN=/caminho/para/Godot_v4.7.2-stable_linux.x86_64 ./scripts/run_godot_smoke.sh
```

O runner executa três cenários:

1. **Smoke test**: carrega autoloads, scripts e cenas principais e valida o teardown.
2. **Fluxo completo**: percorre menu, narrativa, transformações, três mini-games, encerramento, replay e retorno ao menu.
3. **Inicialização da Main**: garante que a cena principal inicia no estado esperado e encerra sem resíduos.

Os logs falham quando o Godot reporta erro de script, chamada inválida, erro de parser, vazamento de `ObjectDB` ou recurso ainda em uso.

## Integração contínua

O workflow `.github/workflows/ci.yml` roda em Pull Requests e pushes de `develop` e `main`.

Jobs obrigatórios:

| Job | Objetivo |
|---|---|
| `branch-policy` | Garante a direção `branches de trabalho -> develop -> main` |
| `repository-audit` | Executa validações estáticas e auditoria do diff |
| `godot-tests` | Instala Godot 4.7.2 verificado por SHA-256 e executa os testes de runtime |

A Action `actions/checkout` é fixada por SHA e o token do workflow possui somente permissão de leitura de conteúdo.

## Validação manual

O arquivo `tests/manual/ROTEIRO_TESTE_FUNCIONAL.md` contém 30 casos para conferir comportamento visual e interação real no editor. Esse roteiro é recomendado antes de demonstrações e entregas.
