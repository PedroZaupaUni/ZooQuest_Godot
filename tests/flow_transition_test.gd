extends Node

const MainScene := preload("res://core/main.tscn")

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

func _assert_phase(expected: String, context: String) -> void:
    if game_state == null:
        _fail(context + ": GameState indisponivel")
        return
    var actual := str(game_state.get("current_phase"))
    if actual != expected:
        _fail("%s: esperado phase=%s, atual=%s" % [context, expected, actual])

func _assert_int_property(object: Object, property_name: String, expected: int, context: String) -> void:
    var actual := int(object.get(property_name))
    if actual != expected:
        _fail("%s: esperado %s=%d, atual=%d" % [context, property_name, expected, actual])

func _press_accept_on(stage: Node) -> void:
    if stage == null or not is_instance_valid(stage):
        _fail("Stage invalido ao simular ENTER")
        return
    if not stage.has_method("_unhandled_key_input"):
        _fail("Stage sem _unhandled_key_input: " + str(stage))
        return
    var event := InputEventKey.new()
    event.keycode = KEY_ENTER
    event.physical_keycode = KEY_ENTER
    event.pressed = true
    stage.call("_unhandled_key_input", event)

func _settle(frames: int = 2) -> void:
    for _i in range(frames):
        await get_tree().process_frame

func _run() -> void:
    if game_state == null:
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        get_tree().quit(1)
        return

    var main = MainScene.instantiate()
    add_child(main)
    await _settle(2)
    _assert_phase("menu", "inicio")

    main.call("_start_game")
    await _settle(2)
    _assert_phase("intro", "apos iniciar")

    # Intro: 3 paginas.
    _press_accept_on(main.current_stage)
    await _settle(1)
    _assert_phase("intro", "intro pagina 2")
    _press_accept_on(main.current_stage)
    await _settle(1)
    _assert_phase("intro", "intro pagina 3")
    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("transform_frog", "intro -> transform_frog")

    # O bug FIX1 ocorreu neste tipo de transicao por teclado.
    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("frog", "transform_frog -> frog")
    main.current_stage.completed.emit()
    await _settle(2)
    _assert_phase("return_human_1", "frog -> return_human_1")

    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("between_frog_bird", "return_human_1 -> narrativa")
    _press_accept_on(main.current_stage)
    await _settle(1)
    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("transform_bird", "narrativa -> transform_bird")

    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("bird", "transform_bird -> bird")
    main.current_stage.completed.emit()
    await _settle(2)
    _assert_phase("return_human_2", "bird -> return_human_2")

    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("between_bird_worm", "return_human_2 -> narrativa")
    _press_accept_on(main.current_stage)
    await _settle(1)
    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("transform_worm", "narrativa -> transform_worm")

    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("worm", "transform_worm -> worm")
    main.current_stage.completed.emit()
    await _settle(2)
    _assert_phase("return_human_3", "worm -> return_human_3")

    _press_accept_on(main.current_stage)
    await _settle(2)
    _assert_phase("ending", "return_human_3 -> ending")

    # Replay deve reiniciar estado global e voltar para a introducao.
    game_state.call("register_correct", 10)
    game_state.call("register_wrong")
    main.current_stage.replay_requested.emit()
    await _settle(2)
    _assert_phase("intro", "ending -> replay -> intro")
    _assert_int_property(game_state, "score", 0, "replay")
    _assert_int_property(game_state, "correct_answers", 0, "replay")
    _assert_int_property(game_state, "wrong_answers", 0, "replay")

    # Menu deve permanecer acessivel durante a narrativa.
    main.current_stage.menu_requested.emit()
    await _settle(2)
    _assert_phase("menu", "narrativa -> menu")

    main.queue_free()
    await _settle(1)

    if failures.is_empty():
        print("ZOOQUEST_FLOW_TRANSITION_TEST=PASS")
        get_tree().quit(0)
    else:
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        print("FAILURES=" + str(failures.size()))
        get_tree().quit(1)
