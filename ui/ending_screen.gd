extends Control

signal replay_requested
signal menu_requested

const UI := preload("res://shared/ui_helpers.gd")
const Portrait := preload("res://ui/character_portrait.gd")

func _ready() -> void:
    AudioManager.play_sfx("finish", -7.0)
    _build_interface()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color(0.08, 0.28, 0.22))
    draw_rect(Rect2(0, 505, 1280, 215), Color(0.13, 0.48, 0.27))
    for i in range(50):
        var x := float((i * 83) % 1280)
        var y := float((i * 137) % 480)
        var colors := [Color(1.0, 0.82, 0.24), Color(0.39, 0.82, 0.96), Color(0.96, 0.40, 0.42), Color(0.52, 0.90, 0.46)]
        draw_circle(Vector2(x, y), 3.0 + float(i % 4), colors[i % colors.size()])

func _build_interface() -> void:
    var heading := UI.make_label("JORNADA CONCLUIDA!", 52, Color(1.0, 0.87, 0.35))
    heading.position = Vector2(180, 40)
    heading.size = Vector2(920, 72)
    add_child(heading)

    var portrait = Portrait.new()
    portrait.position = Vector2(95, 175)
    portrait.size = Vector2(310, 310)
    portrait.configure("human", Color(0.93, 0.46, 0.20), true)
    add_child(portrait)

    var panel := Panel.new()
    panel.position = Vector2(390, 135)
    panel.size = Vector2(760, 400)
    panel.add_theme_stylebox_override("panel", UI.make_panel_style(Color(1, 1, 1, 0.96), Color(1.0, 0.78, 0.20), 26, 5))
    add_child(panel)

    var lesson := UI.make_label("Aprender tambem e observar, tentar novamente e compreender as consequencias das escolhas.", 24, Color(0.09, 0.24, 0.18))
    lesson.position = Vector2(45, 28)
    lesson.size = Vector2(670, 100)
    panel.add_child(lesson)

    var stars := _star_text()
    var stars_label := UI.make_label(stars, 48, Color(0.95, 0.65, 0.08))
    stars_label.position = Vector2(110, 125)
    stars_label.size = Vector2(540, 66)
    panel.add_child(stars_label)

    var score_label := UI.make_label("Pontuacao: %d de 90" % GameState.score, 34, Color(0.12, 0.48, 0.30))
    score_label.position = Vector2(80, 194)
    score_label.size = Vector2(600, 55)
    panel.add_child(score_label)

    var stats := UI.make_label("Acertos: %d    |    Tentativas incorretas: %d" % [GameState.correct_answers, GameState.wrong_answers], 22, Color(0.16, 0.25, 0.22))
    stats.position = Vector2(70, 250)
    stats.size = Vector2(620, 48)
    panel.add_child(stats)

    var status := UI.make_label(_performance_message(), 20, Color(0.22, 0.33, 0.28))
    status.position = Vector2(60, 300)
    status.size = Vector2(640, 70)
    panel.add_child(status)

    var replay_button := UI.make_button("JOGAR NOVAMENTE", Vector2(300, 62), Color(0.12, 0.51, 0.31))
    replay_button.position = Vector2(360, 585)
    replay_button.pressed.connect(_on_replay_pressed)
    add_child(replay_button)
    replay_button.grab_focus()

    var menu_button := UI.make_button("VOLTAR AO MENU", Vector2(270, 62), Color(0.16, 0.40, 0.62))
    menu_button.position = Vector2(680, 585)
    menu_button.pressed.connect(_on_menu_pressed)
    add_child(menu_button)

func _star_text() -> String:
    if GameState.score >= 80:
        return "★  ★  ★"
    if GameState.score >= 50:
        return "★  ★  ☆"
    return "★  ☆  ☆"

func _performance_message() -> String:
    if GameState.wrong_answers == 0:
        return "Excelente! Voce concluiu todos os desafios sem respostas incorretas."
    if GameState.wrong_answers <= 4:
        return "Muito bem! Os erros fizeram parte do aprendizado e voce continuou tentando."
    return "Parabens pela persistencia! Jogue novamente para praticar e melhorar sua pontuacao."

func _on_replay_pressed() -> void:
    replay_requested.emit()

func _on_menu_pressed() -> void:
    menu_requested.emit()
