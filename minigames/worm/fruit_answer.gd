extends Area2D

signal selected(answer_index: int)

const UI := preload("res://shared/ui_helpers.gd")

var answer_index: int = -1
var answer_text: String = ""
var active: bool = true
var fruit_color: Color = Color(0.92, 0.25, 0.24)
var answer_label: Label

func _ready() -> void:
    input_pickable = true
    collision_layer = 2
    collision_mask = 1
    monitoring = true
    var collision := CollisionShape2D.new()
    var shape := CircleShape2D.new()
    shape.radius = 55.0
    collision.shape = shape
    add_child(collision)
    body_entered.connect(_on_body_entered)

    answer_label = UI.make_label(answer_text, 20, Color.WHITE)
    answer_label.position = Vector2(-110, 56)
    answer_label.size = Vector2(220, 60)
    answer_label.add_theme_stylebox_override("normal", UI.make_panel_style(Color(0.12, 0.19, 0.15, 0.92), Color(1.0, 0.83, 0.30), 13, 2))
    answer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(answer_label)
    queue_redraw()

func configure(index: int, text_value: String, color_value: Color) -> void:
    answer_index = index
    answer_text = text_value
    fruit_color = color_value
    active = true
    if answer_label != null:
        answer_label.text = answer_text
    queue_redraw()

func set_active(value: bool) -> void:
    active = value

func _draw() -> void:
    draw_circle(Vector2.ZERO, 46, fruit_color)
    draw_circle(Vector2(-17, -14), 13, fruit_color.lightened(0.12))
    draw_circle(Vector2(17, -14), 13, fruit_color.lightened(0.08))
    draw_line(Vector2(0, -43), Vector2(6, -72), Color(0.36, 0.22, 0.09), 8)
    draw_colored_polygon(PackedVector2Array([Vector2(5, -66), Vector2(35, -80), Vector2(21, -52)]), Color(0.24, 0.65, 0.28))
    draw_circle(Vector2(-14, -12), 8, Color(1, 1, 1, 0.18))

func _on_body_entered(body: Node) -> void:
    if active and body.is_in_group("worm_player"):
        active = false
        selected.emit(answer_index)

func _input_event(_viewport, event, _shape_idx) -> void:
    if active and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        active = false
        selected.emit(answer_index)
