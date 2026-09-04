extends Node

const SCENES := [
    "res://core/main.tscn",
    "res://ui/main_menu.tscn",
    "res://ui/narrative_screen.tscn",
    "res://ui/transformation_screen.tscn",
    "res://ui/ending_screen.tscn",
    "res://ui/hud.tscn",
    "res://minigames/frog/frog_minigame.tscn",
    "res://minigames/bird/bird_minigame.tscn",
    "res://minigames/worm/worm_minigame.tscn"
]

const SCRIPTS := [
    "res://core/main.gd",
    "res://core/game_state.gd",
    "res://core/audio_manager.gd",
    "res://data/question_bank.gd",
    "res://data/flow_repository.gd",
    "res://ui/main_menu.gd",
    "res://ui/narrative_screen.gd",
    "res://ui/transformation_screen.gd",
    "res://ui/ending_screen.gd",
    "res://ui/hud.gd",
    "res://minigames/frog/frog_minigame.gd",
    "res://minigames/bird/bird_minigame.gd",
    "res://minigames/worm/worm_minigame.gd"
]

const AUTOLOADS := [
    "GameState",
    "QuestionBank",
    "FlowRepository",
    "AudioManager"
]

var failures: Array[String] = []

func _ready() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    failures.append(message)
    push_error(message)

func _settle(frames: int = 2) -> void:
    for _i in range(frames):
        await get_tree().process_frame

func _prepare_test_runtime() -> void:
    var audio_manager: Node = get_node_or_null("/root/AudioManager")
    if audio_manager == null:
        _fail("AudioManager ausente no runtime")
        return
    if not audio_manager.has_method("set_sfx_enabled"):
        _fail("AudioManager sem set_sfx_enabled para testes headless")
        return

    # O smoke testa compilacao/instanciacao, nao o mixer de audio. Desabilitar
    # SFX antes de instanciar as cenas impede AudioStreamPlayer efemero de
    # contaminar o shutdown do runner headless, sem alterar o gameplay normal.
    audio_manager.call("set_sfx_enabled", false)
    await _settle(2)

func _assert_clean_audio() -> void:
    var audio_manager: Node = get_node_or_null("/root/AudioManager")
    if audio_manager == null:
        _fail("AudioManager ausente no teardown")
        return
    if not audio_manager.has_method("stop_all_sfx") or not audio_manager.has_method("active_sfx_count"):
        _fail("AudioManager sem contrato de teardown deterministico")
        return

    audio_manager.call("stop_all_sfx")
    await _settle(3)
    var remaining: int = int(audio_manager.call("active_sfx_count"))
    if remaining != 0:
        _fail("Audio players ativos apos teardown do smoke: %d" % remaining)

func _run() -> void:
    await _prepare_test_runtime()

    for autoload_name in AUTOLOADS:
        var singleton: Node = get_node_or_null("/root/" + autoload_name)
        if singleton == null:
            _fail("Autoload ausente no runtime: " + autoload_name)

    var question_bank: Node = get_node_or_null("/root/QuestionBank")
    if question_bank != null and not bool(question_bank.call("is_ready_for_game")):
        _fail("QuestionBank carregou, mas nao esta pronto para o jogo")

    var flow_repository: Node = get_node_or_null("/root/FlowRepository")
    if flow_repository != null and not bool(flow_repository.call("is_ready_for_game")):
        _fail("FlowRepository carregou, mas nao esta pronto para o jogo")

    # Carrega explicitamente os scripts principais para transformar erro de parse
    # ou compilacao em falha do smoke antes de qualquer merge.
    for script_path in SCRIPTS:
        var script_resource: Resource = ResourceLoader.load(script_path)
        if script_resource == null:
            _fail("Falha ao carregar script: " + script_path)
            continue
        if not script_resource is Script:
            _fail("Recurso nao e Script: " + script_path)
            continue

        var script: Script = script_resource as Script
        if not script.can_instantiate():
            _fail("Script nao pode ser instanciado/compilado: " + script_path)

        script = null
        script_resource = null

    # Cada cena e colocada no SceneTree e depois destruida SINCRONAMENTE. Isso
    # valida _ready() e os preloads, mas nao deixa queue_free pendente no quit.
    for scene_path in SCENES:
        var scene_resource: Resource = ResourceLoader.load(scene_path)
        if scene_resource == null:
            _fail("Falha ao carregar cena: " + scene_path)
            continue
        if not scene_resource is PackedScene:
            _fail("Recurso nao e PackedScene: " + scene_path)
            continue

        var packed_scene: PackedScene = scene_resource as PackedScene
        var instance: Node = packed_scene.instantiate()
        if instance == null:
            _fail("Falha ao instanciar cena: " + scene_path)
            continue

        add_child(instance)
        await _settle(2)

        if is_instance_valid(instance):
            if instance.get_parent() == self:
                remove_child(instance)
            instance.free()

        instance = null
        packed_scene = null
        scene_resource = null
        await _settle(2)

    await _assert_clean_audio()

    var exit_code: int = 0
    if failures.is_empty():
        print("ZOOQUEST_SMOKE_TEARDOWN=PASS")
        print("ZOOQUEST_GODOT_SMOKE=PASS")
    else:
        exit_code = 1
        print("ZOOQUEST_GODOT_SMOKE=FAIL")
        print("FAILURES=" + str(failures.size()))

    # Agenda o quit diretamente no SceneTree. _run() retorna antes de o motor
    # encerrar, eliminando a coroutine _finish que mantinha referencias vivas.
    get_tree().call_deferred("quit", exit_code)
