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

func _cleanup_audio() -> void:
    var audio_manager: Node = get_node_or_null("/root/AudioManager")
    if audio_manager == null:
        _fail("AudioManager ausente durante teardown do smoke")
        return
    if not audio_manager.has_method("stop_all_sfx") or not audio_manager.has_method("active_sfx_count"):
        _fail("AudioManager sem contrato de teardown deterministico")
        return

    audio_manager.call("stop_all_sfx")
    # queue_free() e processado ao fim do frame. Dois frames deixam o teardown
    # independente da ordem em que sinais finished/deletion forem drenados.
    await get_tree().process_frame
    await get_tree().process_frame

    var remaining: int = int(audio_manager.call("active_sfx_count"))
    if remaining != 0:
        _fail("Audio players ativos apos teardown do smoke: %d" % remaining)

func _finish(exit_code: int) -> void:
    # Deixe _run() retornar antes de encerrar o SceneTree para liberar referencias
    # locais de Resource/PackedScene/Script usadas durante a auditoria.
    await get_tree().process_frame
    get_tree().quit(exit_code)

func _run() -> void:
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

    for script_path in SCRIPTS:
        var script_resource: Resource = ResourceLoader.load(
            script_path,
            "",
            ResourceLoader.CACHE_MODE_IGNORE
        )
        if script_resource == null:
            _fail("Falha ao carregar script: " + script_path)
            continue
        if not script_resource is Script:
            _fail("Recurso nao e Script: " + script_path)
            continue

        var script: Script = script_resource as Script
        if not script.can_instantiate():
            _fail("Script nao pode ser instanciado/compilado: " + script_path)

    for scene_path in SCENES:
        var scene_resource: Resource = ResourceLoader.load(
            scene_path,
            "",
            ResourceLoader.CACHE_MODE_IGNORE
        )
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
        await get_tree().process_frame
        instance.queue_free()
        await get_tree().process_frame

    # Algumas cenas disparam SFX no _ready(). Como AudioManager e autoload,
    # esses players sobrevivem ao free da cena e precisam ser drenados antes
    # do encerramento acelerado do teste.
    await _cleanup_audio()

    var exit_code: int = 0
    if failures.is_empty():
        print("ZOOQUEST_GODOT_SMOKE=PASS")
    else:
        exit_code = 1
        print("ZOOQUEST_GODOT_SMOKE=FAIL")
        print("FAILURES=" + str(failures.size()))

    call_deferred("_finish", exit_code)
