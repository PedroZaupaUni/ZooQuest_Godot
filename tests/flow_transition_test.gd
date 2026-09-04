extends Node

var failures: Array[String] = []
var game_state: Node = null

func _ready() -> void:
    game_state = get_node_or_null("/root/GameState")
    if game_state == null:
        _fail("Autoload GameState ausente")
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
        _fail("AudioManager ausente durante preparacao do flow")
        return
    if not audio_manager.has_method("set_sfx_enabled"):
        _fail("AudioManager sem set_sfx_enabled")
        return
    audio_manager.call("set_sfx_enabled", false)
    await _settle(2)

func _cleanup_audio() -> void:
    var audio_manager: Node = get_node_or_null("/root/AudioManager")
    if audio_manager == null:
        _fail("AudioManager ausente durante teardown do flow")
        return
    if not audio_manager.has_method("stop_all_sfx") or not audio_manager.has_method("active_sfx_count"):
        _fail("AudioManager sem contrato de teardown deterministico")
        return

    audio_manager.call("stop_all_sfx")
    await _settle(3)
    var remaining: int = int(audio_manager.call("active_sfx_count"))
    if remaining != 0:
        _fail("Audio players ativos apos teardown do flow: %d" % remaining)

func _assert_phase(expected: String, context: String) -> void:
    if game_state == null:
        _fail(context + ": GameState indisponivel")
        return
    var actual: String = str(game_state.get("current_phase"))
    if actual != expected:
        _fail("%s: esperado phase=%s, atual=%s" % [context, expected, actual])

func _assert_int_property(object: Object, property_name: String, expected: int, context: String) -> void:
    var actual: int = int(object.get(property_name))
    if actual != expected:
        _fail("%s: esperado %s=%d, atual=%d" % [context, property_name, expected, actual])

func _current_stage(main: Node, context: String) -> Node:
    if main == null or not is_instance_valid(main):
        _fail(context + ": Main invalida")
        return null
    var stage: Node = main.get("current_stage") as Node
    if stage == null or not is_instance_valid(stage):
        _fail(context + ": current_stage invalido")
        return null
    return stage

func _press_accept(main: Node, context: String) -> void:
    var stage: Node = _current_stage(main, context)
    if stage == null:
        return
    if not stage.has_method("_unhandled_key_input"):
        _fail(context + ": stage sem _unhandled_key_input")
        return

    var event := InputEventKey.new()
    event.keycode = KEY_ENTER
    event.physical_keycode = KEY_ENTER
    event.pressed = true
    stage.call("_unhandled_key_input", event)

func _emit_stage_signal(main: Node, signal_name: String, context: String) -> void:
    var stage: Node = _current_stage(main, context)
    if stage == null:
        return
    if not stage.has_signal(signal_name):
        _fail("%s: stage sem signal %s" % [context, signal_name])
        return
    stage.emit_signal(signal_name)

func _run() -> void:
    await _prepare_test_runtime()

    if game_state == null:
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        get_tree().call_deferred("quit", 1)
        return

    var main_resource: Resource = ResourceLoader.load("res://core/main.tscn")
    if main_resource == null or not main_resource is PackedScene:
        _fail("Nao foi possivel carregar core/main.tscn")
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        get_tree().call_deferred("quit", 1)
        return

    var main_scene: PackedScene = main_resource as PackedScene
    var main: Node = main_scene.instantiate()
    if main == null:
        _fail("Nao foi possivel instanciar core/main.tscn")
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        get_tree().call_deferred("quit", 1)
        return

    add_child(main)
    await _settle(3)
    _assert_phase("menu", "inicio")

    main.call("_start_game")
    await _settle(3)
    _assert_phase("intro", "apos iniciar")

    # Intro: 3 paginas.
    _press_accept(main, "intro pagina 1")
    await _settle(2)
    _assert_phase("intro", "intro pagina 2")
    _press_accept(main, "intro pagina 2")
    await _settle(2)
    _assert_phase("intro", "intro pagina 3")
    _press_accept(main, "intro pagina 3")
    await _settle(3)
    _assert_phase("transform_frog", "intro -> transform_frog")

    # Regressao do bug FIX1: ENTER na transformacao nao pode perder viewport.
    _press_accept(main, "transform_frog")
    await _settle(3)
    _assert_phase("frog", "transform_frog -> frog")
    _emit_stage_signal(main, "completed", "frog")
    await _settle(3)
    _assert_phase("return_human_1", "frog -> return_human_1")

    _press_accept(main, "return_human_1")
    await _settle(3)
    _assert_phase("between_frog_bird", "return_human_1 -> narrativa")
    _press_accept(main, "between_frog_bird pagina 1")
    await _settle(2)
    _press_accept(main, "between_frog_bird pagina 2")
    await _settle(3)
    _assert_phase("transform_bird", "narrativa -> transform_bird")

    _press_accept(main, "transform_bird")
    await _settle(3)
    _assert_phase("bird", "transform_bird -> bird")
    _emit_stage_signal(main, "completed", "bird")
    await _settle(3)
    _assert_phase("return_human_2", "bird -> return_human_2")

    _press_accept(main, "return_human_2")
    await _settle(3)
    _assert_phase("between_bird_worm", "return_human_2 -> narrativa")
    _press_accept(main, "between_bird_worm pagina 1")
    await _settle(2)
    _press_accept(main, "between_bird_worm pagina 2")
    await _settle(3)
    _assert_phase("transform_worm", "narrativa -> transform_worm")

    _press_accept(main, "transform_worm")
    await _settle(3)
    _assert_phase("worm", "transform_worm -> worm")
    _emit_stage_signal(main, "completed", "worm")
    await _settle(3)
    _assert_phase("return_human_3", "worm -> return_human_3")

    _press_accept(main, "return_human_3")
    await _settle(3)
    _assert_phase("ending", "return_human_3 -> ending")

    # Replay deve limpar o estado global e voltar para a introducao.
    game_state.call("register_correct", 10)
    game_state.call("register_wrong")
    _emit_stage_signal(main, "replay_requested", "ending")
    await _settle(3)
    _assert_phase("intro", "ending -> replay -> intro")
    _assert_int_property(game_state, "score", 0, "replay")
    _assert_int_property(game_state, "correct_answers", 0, "replay")
    _assert_int_property(game_state, "wrong_answers", 0, "replay")

    # Menu deve continuar acessivel durante a narrativa.
    _emit_stage_signal(main, "menu_requested", "intro apos replay")
    await _settle(3)
    _assert_phase("menu", "narrativa -> menu")

    # Destruicao sincrona impede current_stage/children pendentes no shutdown.
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
        print("ZOOQUEST_FLOW_TEARDOWN=PASS")
        print("ZOOQUEST_FLOW_TRANSITION_TEST=PASS")
    else:
        exit_code = 1
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        print("FAILURES=" + str(failures.size()))

    get_tree().call_deferred("quit", exit_code)
