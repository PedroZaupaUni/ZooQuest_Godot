extends Node

var failures: Array[String] = []
var game_state: Node = null

func _ready() -> void:
    game_state = get_node_or_null("/root/GameState")
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
        _fail("AudioManager ausente no main startup")
        return
    if not audio_manager.has_method("set_sfx_enabled"):
        _fail("AudioManager sem set_sfx_enabled")
        return
    audio_manager.call("set_sfx_enabled", false)
    await _settle(2)

func _cleanup_audio() -> void:
    var audio_manager: Node = get_node_or_null("/root/AudioManager")
    if audio_manager == null:
        _fail("AudioManager ausente no teardown do main startup")
        return
    audio_manager.call("stop_all_sfx")
    await _settle(3)
    if int(audio_manager.call("active_sfx_count")) != 0:
        _fail("Audio ativo apos teardown do main startup")

func _run() -> void:
    await _prepare_test_runtime()

    if game_state == null:
        _fail("GameState ausente")

    var question_bank: Node = get_node_or_null("/root/QuestionBank")
    var flow_repository: Node = get_node_or_null("/root/FlowRepository")
    if question_bank == null or not bool(question_bank.call("is_ready_for_game")):
        _fail("QuestionBank nao esta pronto")
    if flow_repository == null or not bool(flow_repository.call("is_ready_for_game")):
        _fail("FlowRepository nao esta pronto")

    var main_resource: Resource = ResourceLoader.load("res://core/main.tscn")
    if main_resource == null or not main_resource is PackedScene:
        _fail("core/main.tscn nao carregou como PackedScene")
    else:
        var main_scene: PackedScene = main_resource as PackedScene
        var main: Node = main_scene.instantiate()
        if main == null:
            _fail("core/main.tscn nao pode ser instanciada")
        else:
            add_child(main)
            await _settle(4)

            if game_state != null and str(game_state.get("current_phase")) != "menu":
                _fail("Main nao iniciou na fase menu")

            var stage_host: Node = main.get_node_or_null("StageHost")
            if stage_host == null:
                _fail("Main sem StageHost")

            var current_stage: Node = main.get("current_stage") as Node
            if current_stage == null or not is_instance_valid(current_stage):
                _fail("Main sem current_stage valido")
            elif stage_host != null and current_stage.get_parent() != stage_host:
                _fail("current_stage nao esta montado no StageHost")
            elif not current_stage.has_signal("start_requested"):
                _fail("Tela inicial nao expoe start_requested")

            if stage_host != null and stage_host.get_child_count() != 1:
                _fail("StageHost deveria possuir exatamente uma tela no startup")

            if is_instance_valid(main):
                if main.get_parent() == self:
                    remove_child(main)
                main.free()
            main = null

        main_scene = null
    main_resource = null

    await _settle(3)
    await _cleanup_audio()

    var exit_code: int = 0
    if failures.is_empty():
        print("ZOOQUEST_MAIN_STARTUP_TEARDOWN=PASS")
        print("ZOOQUEST_MAIN_STARTUP=PASS")
    else:
        exit_code = 1
        print("ZOOQUEST_MAIN_STARTUP=FAIL")
        print("FAILURES=" + str(failures.size()))

    get_tree().call_deferred("quit", exit_code)
