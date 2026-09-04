# ZooQuest CI Harness FIX2.3

## Motivo

O FIX2.2 eliminou o erro de tipagem e o smoke passou funcionalmente no Godot 4.7.2, mas a CI encontrou no encerramento:

- `WARNING: 4 ObjectDB instances were leaked at exit`
- `ERROR: 2 resources still in use at exit`

A causa e deterministica: o smoke instancia cenas que disparam efeitos sonoros (`transform` e `finish`). O `AudioManager` e um autoload e cria `AudioStreamPlayer` como filhos globais, liberados normalmente apenas pelo sinal `finished`. Como o smoke encerra em poucos frames, esses players ainda estavam tocando.

## Correcao

1. `AudioManager` agora oferece `stop_all_sfx()` e `active_sfx_count()`.
2. Smoke e flow fazem teardown explicito dos SFX antes de encerrar.
3. Os testes aguardam frames suficientes para processar `queue_free()`.
4. O `quit()` ocorre de forma diferida, depois de `_run()` retornar, liberando referencias locais de recursos.
5. A auditoria de logs passa a tratar tambem `ObjectDB ... leaked at exit` como falha fatal.

## Politica

Nao foi adicionada whitelist para esconder o erro. O objetivo e obter shutdown limpo no Godot, mantendo a CI estrita.
