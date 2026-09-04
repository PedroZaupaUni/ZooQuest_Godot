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

func _run() -> void:
    for autoload_name in AUTOLOADS:
        var singleton := get_node_or_null("/root/" + autoload_name)
        if singleton == null:
            _fail("Autoload ausente no runtime: " + autoload_name)

    var question_bank := get_node_or_null("/root/QuestionBank")
    if question_bank != null and not bool(question_bank.call("is_ready_for_game")):
        _fail("QuestionBank carregou, mas nao esta pronto para o jogo")

    var flow_repository := get_node_or_null("/root/FlowRepository")
    if flow_repository != null and not bool(flow_repository.call("is_ready_for_game")):
        _fail("FlowRepository carregou, mas nao esta pronto para o jogo")

    for script_path in SCRIPTS:
        var script_resource := ResourceLoader.load(script_path, "", ResourceLoader.CACHE_MODE_IGNORE)
        if script_resource == null:
            _fail("Falha ao carregar script: " + script_path)
        elif not script_resource is Script:
            _fail("Recurso nao e Script: " + script_path)
        elif not script_resource.can_instantiate():
            _fail("Script nao pode ser instanciado/compilado: " + script_path)

    for scene_path in SCENES:
        var resource := ResourceLoader.load(scene_path, "", ResourceLoader.CACHE_MODE_IGNORE)
        if resource == null:
            _fail("Falha ao carregar cena: " + scene_path)
            continue
        if not resource is PackedScene:
            _fail("Recurso nao e PackedScene: " + scene_path)
            continue

        var instance := resource.instantiate()
        if instance == null:
            _fail("Falha ao instanciar cena: " + scene_path)
            continue

        add_child(instance)
        await get_tree().process_frame
        instance.queue_free()
        await get_tree().process_frame

    if failures.is_empty():
        print("ZOOQUEST_GODOT_SMOKE=PASS")
        get_tree().quit(0)
    else:
        print("ZOOQUEST_GODOT_SMOKE=FAIL")
        print("FAILURES=" + str(failures.size()))
        get_tree().quit(1)
