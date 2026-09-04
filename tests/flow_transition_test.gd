extends SceneTree

const MainScene := preload("res://core/main.tscn")

var failures: Array[String] = []

func _init() -> void:
    call_deferred("_run")

func _fail(message: String) -> void:
    failures.append(message)
    push_error(message)

func _assert_phase(expected: String, context: String) -> void:
    if GameState.current_phase != expected:
        _fail("%s: esperado phase=%s, atual=%s" % [context, expected, GameState.current_phase])

func _press_accept_on(stage: Node) -> void:
    if not stage.has_method("_unhandled_key_input"):
        _fail("Stage sem _unhandled_key_input: " + str(stage))
        return
    var event := InputEventKey.new()
    event.keycode = KEY_ENTER
    event.physical_keycode = KEY_ENTER
    event.pressed = true
    stage._unhandled_key_input(event)

func _run() -> void:
    var main = MainScene.instantiate()
    root.add_child(main)
    await process_frame
    _assert_phase("menu", "inicio")

    main._start_game()
    await process_frame
    _assert_phase("intro", "apos iniciar")

    # Intro tem 3 paginas; as duas primeiras permanecem na mesma etapa.
    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("intro", "intro pagina 2")
    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("intro", "intro pagina 3")
    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("transform_frog", "intro -> transform_frog")

    # Cada tela de transformacao deve aceitar ENTER sem viewport nulo.
    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("frog", "transform_frog -> frog")
    main.current_stage.completed.emit()
    await process_frame
    _assert_phase("return_human_1", "frog -> return_human_1")

    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("between_frog_bird", "return_human_1 -> narrativa")
    _press_accept_on(main.current_stage)
    await process_frame
    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("transform_bird", "narrativa -> transform_bird")

    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("bird", "transform_bird -> bird")
    main.current_stage.completed.emit()
    await process_frame
    _assert_phase("return_human_2", "bird -> return_human_2")

    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("between_bird_worm", "return_human_2 -> narrativa")
    _press_accept_on(main.current_stage)
    await process_frame
    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("transform_worm", "narrativa -> transform_worm")

    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("worm", "transform_worm -> worm")
    main.current_stage.completed.emit()
    await process_frame
    _assert_phase("return_human_3", "worm -> return_human_3")

    _press_accept_on(main.current_stage)
    await process_frame
    _assert_phase("ending", "return_human_3 -> ending")

    if failures.is_empty():
        print("ZOOQUEST_FLOW_TRANSITION_TEST=PASS")
        quit(0)
    else:
        print("ZOOQUEST_FLOW_TRANSITION_TEST=FAIL")
        print("FAILURES=" + str(failures.size()))
        quit(1)
