extends Node2D

signal completed
signal menu_requested

const HUDScene := preload("res://ui/hud.tscn")
const FrogPlayer := preload("res://characters/frog/frog_player.gd")
const LilyPad := preload("res://minigames/frog/lily_pad.gd")

const START_POSITION := Vector2(640, 585)
const PAD_POSITIONS := [Vector2(335, 410), Vector2(640, 385), Vector2(945, 410)]

var hud
var player
var pads: Array = []
var questions: Array = []
var question_index: int = 0
var selected_index: int = 1
var locked: bool = false

func _ready() -> void:
    questions = QuestionBank.get_questions("frog")
    _build_world()
    _present_question()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color(0.55, 0.85, 0.96))
    draw_circle(Vector2(1120, 250), 58, Color(1.0, 0.88, 0.35))
    draw_rect(Rect2(0, 255, 1280, 465), Color(0.20, 0.63, 0.78))
    for y in range(290, 720, 70):
        draw_line(Vector2(0, y), Vector2(1280, y + 18), Color(1, 1, 1, 0.12), 3)
    draw_rect(Rect2(0, 570, 1280, 150), Color(0.18, 0.47, 0.22))
    draw_rect(Rect2(0, 625, 1280, 95), Color(0.34, 0.24, 0.12))
    for x in range(35, 1260, 90):
        draw_line(Vector2(x, 620), Vector2(x + 14, 570), Color(0.16, 0.50, 0.20), 8)

func _build_world() -> void:
    hud = HUDScene.instantiate()
    add_child(hud)
    hud.configure("Fase 1 - Sapo Matematico", "←/→ ou A/D escolhem | ESPACO pula | 1, 2 e 3 selecionam diretamente")
    hud.menu_requested.connect(_on_menu_requested)

    player = FrogPlayer.new()
    player.position = START_POSITION
    player.z_index = 5
    add_child(player)

    for i in range(3):
        var pad = LilyPad.new()
        pad.position = PAD_POSITIONS[i]
        pad.z_index = 2
        add_child(pad)
        pad.configure(i, str(i + 1))
        pad.selected.connect(_on_pad_clicked)
        pads.append(pad)

func _present_question() -> void:
    locked = false
    hud.hide_feedback()
    if question_index >= questions.size():
        completed.emit()
        return
    var question: Dictionary = questions[question_index]
    hud.set_question(str(question["question"]), question_index + 1, questions.size())
    for i in range(3):
        pads[i].configure(i, str(question["options"][i]))
        pads[i].set_enabled(true)
    selected_index = 1
    _update_selection()
    player.reset_to(START_POSITION)

func _unhandled_key_input(event) -> void:
    if locked or not event.pressed or event.echo:
        return
    if event.is_action_pressed("ui_left") or _key_matches(event, KEY_A):
        selected_index = (selected_index + 2) % 3
        _update_selection()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("ui_right") or _key_matches(event, KEY_D):
        selected_index = (selected_index + 1) % 3
        _update_selection()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("ui_accept"):
        _submit_answer(selected_index)
        get_viewport().set_input_as_handled()
    elif _key_matches(event, KEY_1):
        _submit_answer(0)
    elif _key_matches(event, KEY_2):
        _submit_answer(1)
    elif _key_matches(event, KEY_3):
        _submit_answer(2)

func _key_matches(event, key_value: int) -> bool:
    return event.keycode == key_value or event.physical_keycode == key_value

func _update_selection() -> void:
    for i in range(pads.size()):
        pads[i].set_highlighted(i == selected_index)

func _on_pad_clicked(index: int) -> void:
    if locked:
        return
    selected_index = index
    _update_selection()
    _submit_answer(index)

func _submit_answer(index: int) -> void:
    if locked:
        return
    locked = true
    for pad in pads:
        pad.set_enabled(false)
    var question: Dictionary = questions[question_index]
    var is_correct := index == int(question["correct_index"])
    AudioManager.play_sfx("click", -10.0)
    await player.jump_to(PAD_POSITIONS[index] + Vector2(0, -75), is_correct)
    if not is_inside_tree():
        return
    if is_correct:
        GameState.register_correct()
        AudioManager.play_sfx("correct")
        hud.show_feedback("Correto! " + str(question["explanation"]), true)
        await get_tree().create_timer(1.35).timeout
        if not is_inside_tree():
            return
        question_index += 1
        _present_question()
    else:
        GameState.register_wrong()
        AudioManager.play_sfx("wrong")
        hud.show_feedback("Quase! " + str(question["explanation"]), false)
        await get_tree().create_timer(1.50).timeout
        if not is_inside_tree():
            return
        _present_question()

func _on_menu_requested() -> void:
    menu_requested.emit()
