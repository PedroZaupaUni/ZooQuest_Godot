extends Control

signal finished
signal menu_requested

const UI := preload("res://shared/ui_helpers.gd")
const Portrait := preload("res://ui/character_portrait.gd")

var from_form: String = "human"
var to_form: String = "frog"
var screen_title: String = "Transformacao"
var screen_text: String = ""
var elapsed: float = 0.0

func configure(new_from: String, new_to: String, new_title: String, new_text: String) -> void:
    from_form = new_from
    to_form = new_to
    screen_title = new_title
    screen_text = new_text

func _ready() -> void:
    AudioManager.play_sfx("transform", -8.0)
    _build_interface()
    queue_redraw()

func _process(delta: float) -> void:
    elapsed += delta
    queue_redraw()

func _draw() -> void:
    draw_rect(Rect2(0, 0, 1280, 720), Color(0.035, 0.07, 0.12))
    var center := Vector2(640, 350)
    for i in range(8, 0, -1):
        var radius := float(i) * 55.0 + sin(elapsed * 2.4 + float(i)) * 8.0
        var alpha := 0.025 + float(9 - i) * 0.012
        draw_circle(center, radius, Color(0.55, 0.82, 0.96, alpha))
    for i in range(22):
        var angle := float(i) / 22.0 * TAU + elapsed * (0.12 + float(i % 3) * 0.03)
        var radius := 170.0 + float((i * 37) % 210)
        var point := center + Vector2(cos(angle), sin(angle)) * radius
        draw_circle(point, 3.0 + float(i % 4), Color(1.0, 0.85, 0.32, 0.72))

func _build_interface() -> void:
    var title := UI.make_label(screen_title, 46, Color(1.0, 0.86, 0.35))
    title.position = Vector2(150, 40)
    title.size = Vector2(980, 70)
    add_child(title)

    var from_portrait = Portrait.new()
    from_portrait.position = Vector2(195, 190)
    from_portrait.size = Vector2(300, 300)
    from_portrait.configure(from_form, _form_color(from_form), true)
    add_child(from_portrait)

    var arrow := UI.make_label("→", 82, Color(1.0, 0.90, 0.50))
    arrow.position = Vector2(555, 280)
    arrow.size = Vector2(170, 120)
    add_child(arrow)

    var to_portrait = Portrait.new()
    to_portrait.position = Vector2(785, 190)
    to_portrait.size = Vector2(300, 300)
    to_portrait.configure(to_form, _form_color(to_form), true)
    add_child(to_portrait)

    var text_panel := Panel.new()
    text_panel.position = Vector2(215, 500)
    text_panel.size = Vector2(850, 105)
    text_panel.add_theme_stylebox_override("panel", UI.make_panel_style(Color(0.04, 0.15, 0.18, 0.94), Color(0.35, 0.77, 0.82), 20, 3))
    add_child(text_panel)

    var body := UI.make_label(screen_text, 22, Color.WHITE)
    body.position = Vector2(25, 12)
    body.size = Vector2(800, 80)
    text_panel.add_child(body)

    var continue_button := UI.make_button("CONTINUAR", Vector2(250, 58), Color(0.18, 0.55, 0.62))
    continue_button.position = Vector2(515, 630)
    continue_button.pressed.connect(_on_continue_pressed)
    add_child(continue_button)
    continue_button.grab_focus()

    var menu_button := UI.make_button("MENU", Vector2(135, 48), Color(0.25, 0.32, 0.42))
    menu_button.position = Vector2(30, 28)
    menu_button.pressed.connect(_on_menu_pressed)
    add_child(menu_button)

func _unhandled_key_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_accept"):
        # A tela pode ser removida do SceneTree quando o sinal de navegacao for emitido.
        # Marque o evento como tratado antes da troca para evitar viewport nulo e
        # impedir que a mesma tecla atravesse para a proxima etapa.
        var viewport := get_viewport()
        if viewport != null:
            viewport.set_input_as_handled()
        _on_continue_pressed()

func _form_color(form: String) -> Color:
    match form:
        "frog":
            return Color(0.35, 0.76, 0.29)
        "bird":
            return Color(0.20, 0.55, 0.88)
        "worm":
            return Color(0.86, 0.35, 0.39)
        _:
            return Color(0.93, 0.46, 0.20)

func _on_continue_pressed() -> void:
    AudioManager.play_sfx("click")
    finished.emit()

func _on_menu_pressed() -> void:
    menu_requested.emit()
