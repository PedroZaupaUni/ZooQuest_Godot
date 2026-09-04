# Aplicar e testar FIX1

## 1. Validacao estatica

```bash
python3 scripts/validate_repository.py
python3 scripts/validate_runtime_patterns.py
```

Ambos devem terminar em `PASS`.

## 2. Teste de fluxo sem interface grafica

No Linux, informe o executavel Godot 4.7.2:

```bash
GODOT=/caminho/para/Godot_v4.7.2-stable_linux.x86_64
"$GODOT" --headless --path . --script tests/smoke_test.gd
"$GODOT" --headless --path . --script tests/flow_transition_test.gd
```

Esperado:

```text
ZOOQUEST_GODOT_SMOKE=PASS
ZOOQUEST_FLOW_TRANSITION_TEST=PASS
```

## 3. Reteste manual prioritario

1. F5 -> JOGAR.
2. Avance a introducao usando ENTER/ESPACO.
3. Entre no Sapo.
4. Complete as 3 perguntas.
5. Na tela `Primeiro desafio concluido!`, pressione ENTER/ESPACO.
6. Avance as mensagens ate `Transformacao: Passaro Logico`.
7. Pressione ENTER/ESPACO e confirme que o Passaro inicia sem erro no Debugger.
8. Complete as 3 perguntas do Passaro.
9. Confirme retorno humano sem erro.
10. Complete a Minhoca.
11. Confirme Ending, `JOGAR NOVAMENTE` e `VOLTAR AO MENU`.

Durante todo o teste, o painel Debugger deve permanecer com `Erros (0)`.
