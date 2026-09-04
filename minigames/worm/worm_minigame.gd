extends Node2D

signal completed
signal menu_requested

const HUDScene := preload("res://ui/hud.tscn")
const WormPlayer := preload("res://characters/worm/worm_player.gd")
const FruitAnswer := preload("res://minigames/worm/fruit_answer.gd")

const START_POSITION := Vector2(640, 560)
const FRUIT_POSITIONS := [Vector2(310, 360), Vector2(640, 300), Vector2(970, 380)]
const FRUIT_COLORS := [Color(0.94, 0.28, 0.25), Color(0.96, 0.62, 0.16), Color(0.54, 0.30, 0.78)]

var hud
var player
var fruits: Array = []
var questions: Array = []
var question_index: int = 0
var locked: bool = false

func _ready() -> void:
    questions = QuestionBank.get_questions("worm")
    _build_world()
    _present_question()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color(0.76, 0.91, 0.55))
    draw_rect(Rect2(0, 240, 1280, 480), Color(0.46, 0.68, 0.28))
    for x in range(0, 1280, 100):
        draw_rect(Rect2(x, 255, 58, 465), Color(0.40, 0.27, 0.13))
    for x in range(45, 1280, 180):
        draw_circle(Vector2(x, 280), 44, Color(0.17, 0.50, 0.22))
        draw_circle(Vector2(x + 42, 285), 37, Color(0.20, 0.58, 0.26))
    for i in range(35):
        var p := Vector2(float((i * 97) % 1280), 260.0 + float((i * 53) % 430))
        draw_circle(p, 4.0 + float(i % 3), [Color(0.95, 0.43, 0.48), Color(1.0, 0.82, 0.25), Color(0.55, 0.36, 0.82)][i % 3])

func _build_world() -> void:
    hud = HUDScene.instantiate()
    add_child(hud)
    hud.configure("Fase 3 - Minhoca das Escolhas", "Setas ou WASD movimentam | Encoste ou clique na fruta correta | 1, 2 e 3 selecionam")
    hud.menu_requested.connect(_on_menu_requested)

    player = WormPlayer.new()
    player.position = START_POSITION
    player.z_index = 4
    add_child(player)

    for i in range(3):
        var fruit = FruitAnswer.new()
        fruit.position = FRUIT_POSITIONS[i]
        fruit.z_index = 2
        add_child(fruit)
        fruit.configure(i, str(i + 1), FRUIT_COLORS[i])
        fruit.selected.connect(_on_fruit_selected)
        fruits.append(fruit)

func _present_question() -> void:
    locked = false
    hud.hide_feedback()
    if question_index >= questions.size():
        completed.emit()
        return
    var question: Dictionary = questions[question_index]
    hud.set_question(str(question["question"]), question_index + 1, questions.size())
    for i in range(3):
        fruits[i].configure(i, str(question["options"][i]), FRUIT_COLORS[i])
        fruits[i].set_active(true)
    player.reset_to(START_POSITION)

func _unhandled_key_input(event) -> void:
    if locked or not event.pressed or event.echo:
        return
    if _key_matches(event, KEY_1):
        _submit_answer(0)
    elif _key_matches(event, KEY_2):
        _submit_answer(1)
    elif _key_matches(event, KEY_3):
        _submit_answer(2)

func _key_matches(event, key_value: int) -> bool:
    return event.keycode == key_value or event.physical_keycode == key_value

func _on_fruit_selected(index: int) -> void:
    _submit_answer(index)

func _submit_answer(index: int) -> void:
    if locked:
        return
    locked = true
    player.enabled = false
    for fruit in fruits:
        fruit.set_active(false)
    var question: Dictionary = questions[question_index]
    var is_correct := index == int(question["correct_index"])
    if is_correct:
        GameState.register_correct()
        AudioManager.play_sfx("correct")
        hud.show_feedback("Boa escolha! " + str(question["explanation"]), true)
        await player.celebrate()
        if not is_inside_tree():
            return
        await get_tree().create_timer(1.10).timeout
        if not is_inside_tree():
            return
        question_index += 1
        _present_question()
    else:
        GameState.register_wrong()
        AudioManager.play_sfx("wrong")
        hud.show_feedback("Essa escolha tem consequencias. " + str(question["explanation"]), false)
        await get_tree().create_timer(1.55).timeout
        if not is_inside_tree():
            return
        _present_question()

func _on_menu_requested() -> void:
    menu_requested.emit()
