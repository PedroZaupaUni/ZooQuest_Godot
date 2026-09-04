# ZooQuest — Governance FIX2.4

## Motivo

O FIX2.3 comprovou que o smoke funcional executava corretamente (`ZOOQUEST_GODOT_SMOKE=PASS`), mas o processo ainda terminava com `4 ObjectDB instances leaked` e `2 resources still in use`. O numero permaneceu identico ao run anterior, portanto apenas esperar `queue_free()` nao era um teardown deterministico do AudioServer no runner headless.

## Correcoes

1. `AudioManager` ganhou chave explicita `set_sfx_enabled()` e teardown sincrono. `stop_all_sfx()` agora executa `stop()`, remove a referencia `stream`, destaca o node da arvore e usa `free()`.
2. Smoke/flow/startup desabilitam SFX antes de instanciar cenas. Esses testes validam gameplay/navigation/lifecycle, nao o mixer de audio.
3. O smoke nao usa `CACHE_MODE_IGNORE`, libera referencias locais e destrói instancias sincronamente.
4. O flow nao mantem `PackedScene` em `const preload`, nao acessa sinais por tipagem fragil e destrói `Main` sincronamente.
5. Foi criado `main_startup_test.tscn`, substituindo o antigo teste que matava o jogo com `timeout 8s`.
6. Todos os testes Godot usam `--verbose`; qualquer leak futuro mostra as identidades exatas no log.
7. O binario oficial Godot 4.7.2 e validado por SHA-256 antes da execucao.
8. A auditoria estatica exige permanentemente esses contratos.

## SHA-256 oficial fixado

`Godot_v4.7.2-stable_linux.x86_64.zip`

`cadd3204e728a35d3f13adb7fd0d7902636b79f6b95c40c265eb73b6c35329e4`

## Gates

- `repository-audit`
- Godot import + log audit
- smoke + teardown + leak audit
- fluxo completo + replay + teardown + leak audit
- startup da Main + teardown + leak audit
- CI da PR
- CI da main
- somente entao: merge policy, Actions security e ruleset

Nenhum leak e colocado em whitelist. Se o motor ainda reportar `ObjectDB instances leaked`, `resources still in use`, `Leaked instance` ou `Leaked resource`, a CI continua falhando e, com `--verbose`, o log passa a apontar o objeto/recurso exato.
