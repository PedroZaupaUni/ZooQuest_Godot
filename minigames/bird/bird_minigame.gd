extends Node2D

signal completed
signal menu_requested

const HUDScene := preload("res://ui/hud.tscn")
const BirdPlayer := preload("res://characters/bird/bird_player.gd")
const AnswerGate := preload("res://minigames/bird/answer_gate.gd")

const GATE_START_X := 1160.0
const VALIDATE_X := 265.0
const GATE_SPEED := 245.0

var hud
var bird
var gate
var questions: Array = []
var question_index: int = 0
var selected_lane: int = 1
var locked: bool = false

func _ready() -> void:
    questions = QuestionBank.get_questions("bird")
    _build_world()
    _present_question()
    queue_redraw()

func _process(delta: float) -> void:
    if locked or gate == null:
        return
    gate.position.x -= GATE_SPEED * delta
    if gate.position.x <= VALIDATE_X:
        _submit_answer(selected_lane)

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color(0.40, 0.78, 0.96))
    draw_circle(Vector2(1080, 230), 65, Color(1.0, 0.86, 0.31))
    for cloud in [Vector2(190, 235), Vector2(535, 190), Vector2(860, 270)]:
        draw_circle(cloud, 35, Color(1, 1, 1, 0.82))
        draw_circle(cloud + Vector2(42, 6), 29, Color(1, 1, 1, 0.82))
        draw_circle(cloud + Vector2(-40, 8), 25, Color(1, 1, 1, 0.82))
    draw_rect(Rect2(0, 635, 1280, 85), Color(0.18, 0.50, 0.25))
    for x in range(30, 1280, 120):
        draw_colored_polygon(PackedVector2Array([Vector2(x, 635), Vector2(x + 45, 560), Vector2(x + 90, 635)]), Color(0.13, 0.39, 0.21))
    for y in [352.0, 487.0]:
        draw_line(Vector2(0, y), Vector2(1280, y), Color(1, 1, 1, 0.16), 2)

func _build_world() -> void:
    hud = HUDScene.instantiate()
    add_child(hud)
    hud.configure("Fase 2 - Passaro Logico", "↑/↓ ou W/S mudam a passagem | 1, 2 e 3 escolhem diretamente")
    hud.menu_requested.connect(_on_menu_requested)

    bird = BirdPlayer.new()
    bird.z_index = 4
    add_child(bird)

    gate = AnswerGate.new()
    gate.z_index = 2
    add_child(gate)

func _present_question() -> void:
    locked = false
    hud.hide_feedback()
    if question_index >= questions.size():
        completed.emit()
        return
    var question: Dictionary = questions[question_index]
    hud.set_question(str(question["question"]), question_index + 1, questions.size())
    gate.position = Vector2(GATE_START_X, 0)
    gate.set_options(question["options"])
    selected_lane = 1
    gate.set_selected_lane(selected_lane)
    bird.reset_player()

func _unhandled_key_input(event) -> void:
    if locked or not event.pressed or event.echo:
        return
    if event.is_action_pressed("ui_up") or _key_matches(event, KEY_W):
        selected_lane = max(0, selected_lane - 1)
        _apply_lane()
        get_viewport().set_input_as_handled()
    elif event.is_action_pressed("ui_down") or _key_matches(event, KEY_S):
        selected_lane = min(2, selected_lane + 1)
        _apply_lane()
        get_viewport().set_input_as_handled()
    elif _key_matches(event, KEY_1):
        selected_lane = 0
        _apply_lane()
    elif _key_matches(event, KEY_2):
        selected_lane = 1
        _apply_lane()
    elif _key_matches(event, KEY_3):
        selected_lane = 2
        _apply_lane()

func _key_matches(event, key_value: int) -> bool:
    return event.keycode == key_value or event.physical_keycode == key_value

func _apply_lane() -> void:
    bird.set_lane(selected_lane)
    gate.set_selected_lane(selected_lane)
    AudioManager.play_sfx("click", -15.0)

func _submit_answer(index: int) -> void:
    if locked:
        return
    locked = true
    var question: Dictionary = questions[question_index]
    var is_correct := index == int(question["correct_index"])
    if is_correct:
        GameState.register_correct()
        AudioManager.play_sfx("correct")
        hud.show_feedback("Passagem correta! " + str(question["explanation"]), true)
        await bird.play_celebration()
        await get_tree().create_timer(1.05).timeout
        question_index += 1
        _present_question()
    else:
        GameState.register_wrong()
        AudioManager.play_sfx("wrong")
        hud.show_feedback("Colisao! " + str(question["explanation"]), false)
        await bird.play_collision()
        await get_tree().create_timer(1.25).timeout
        _present_question()

func _on_menu_requested() -> void:
    menu_requested.emit()
