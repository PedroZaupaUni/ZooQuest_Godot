extends Control

signal finished
signal menu_requested

const UI := preload("res://shared/ui_helpers.gd")
const Portrait := preload("res://ui/character_portrait.gd")

var screen_title: String = "ZooQuest"
var speaker_name: String = "Narrador"
var pages: Array = []
var page_index: int = 0
var message_label: Label
var page_label: Label
var next_button: Button

func configure(new_title: String, new_pages: Array, new_speaker: String) -> void:
    screen_title = new_title
    pages = new_pages.duplicate(true)
    speaker_name = new_speaker

func _ready() -> void:
    _build_interface()
    _refresh_page()
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color(0.55, 0.82, 0.92))
    draw_rect(Rect2(0, 480, 1280, 240), Color(0.23, 0.58, 0.31))
    draw_rect(Rect2(0, 590, 1280, 130), Color(0.46, 0.35, 0.20))
    for x in range(60, 1280, 160):
        draw_rect(Rect2(x, 320, 15, 180), Color(0.34, 0.22, 0.10))
        draw_circle(Vector2(x + 8, 305), 52, Color(0.18, 0.48, 0.25))
    draw_rect(Rect2(480, 240, 320, 210), Color(0.76, 0.72, 0.55), true)
    draw_rect(Rect2(505, 270, 270, 155), Color(0.45, 0.70, 0.78), true)
    for x in range(520, 775, 35):
        draw_line(Vector2(x, 270), Vector2(x, 425), Color(0.25, 0.28, 0.25), 3)

func _build_interface() -> void:
    var title := UI.make_label(screen_title, 43, Color(0.07, 0.23, 0.17))
    title.position = Vector2(180, 35)
    title.size = Vector2(920, 62)
    add_child(title)

    var portrait = Portrait.new()
    portrait.position = Vector2(75, 165)
    portrait.size = Vector2(260, 270)
    portrait.configure("human", Color(0.93, 0.46, 0.20), true)
    add_child(portrait)

    var panel := Panel.new()
    panel.position = Vector2(310, 135)
    panel.size = Vector2(855, 375)
    panel.add_theme_stylebox_override("panel", UI.make_panel_style(Color(1, 1, 1, 0.94), Color(0.12, 0.44, 0.29), 24, 4))
    add_child(panel)

    var speaker := UI.make_label(speaker_name, 24, Color(0.12, 0.47, 0.30))
    speaker.position = Vector2(35, 24)
    speaker.size = Vector2(300, 44)
    speaker.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    panel.add_child(speaker)

    message_label = UI.make_label("", 27, Color(0.08, 0.16, 0.14))
    message_label.position = Vector2(42, 78)
    message_label.size = Vector2(770, 215)
    message_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    panel.add_child(message_label)

    page_label = UI.make_label("", 17, Color(0.25, 0.34, 0.31))
    page_label.position = Vector2(35, 315)
    page_label.size = Vector2(220, 30)
    page_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
    panel.add_child(page_label)

    next_button = UI.make_button("CONTINUAR", Vector2(240, 56), Color(0.13, 0.50, 0.32))
    next_button.position = Vector2(575, 301)
    next_button.pressed.connect(_on_next_pressed)
    panel.add_child(next_button)
    next_button.grab_focus()

    var menu_button := UI.make_button("MENU", Vector2(135, 48), Color(0.26, 0.36, 0.43))
    menu_button.position = Vector2(30, 28)
    menu_button.pressed.connect(_on_menu_pressed)
    add_child(menu_button)

    var hint := UI.make_label("Clique em Continuar ou pressione ENTER/ESPACO", 18, Color.WHITE)
    hint.position = Vector2(365, 640)
    hint.size = Vector2(550, 36)
    add_child(hint)

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        # A tela pode ser removida do SceneTree quando o sinal de navegacao for emitido.
        # Marque o evento como tratado antes da troca para evitar viewport nulo e
        # impedir que a mesma tecla atravesse para a proxima etapa.
        var viewport := get_viewport()
        if viewport != null:
            viewport.set_input_as_handled()
        _on_next_pressed()

func _refresh_page() -> void:
    if pages.is_empty():
        pages = ["A jornada continua."]
    page_index = clamp(page_index, 0, pages.size() - 1)
    message_label.text = str(pages[page_index])
    page_label.text = "Mensagem %d de %d" % [page_index + 1, pages.size()]
    next_button.text = "CONTINUAR" if page_index < pages.size() - 1 else "SEGUIR JORNADA"

func _on_next_pressed() -> void:
    AudioManager.play_sfx("click")
    if page_index < pages.size() - 1:
        page_index += 1
        _refresh_page()
    else:
        finished.emit()

func _on_menu_pressed() -> void:
    menu_requested.emit()
