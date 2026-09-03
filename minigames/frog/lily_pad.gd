extends Area2D

signal selected(answer_index: int)

const UI := preload("res://shared/ui_helpers.gd")

var answer_index: int = -1
var answer_text: String = ""
var highlighted: bool = false
var enabled: bool = true
var answer_label: Label

func _ready() -> void:
    input_pickable = true
    collision_layer = 2
    collision_mask = 0
    var collision := CollisionShape2D.new()
    var shape := RectangleShape2D.new()
    shape.size = Vector2(190, 95)
    collision.shape = shape
    add_child(collision)

    answer_label = UI.make_label(answer_text, 28, Color.WHITE)
    answer_label.position = Vector2(-85, -40)
    answer_label.size = Vector2(170, 70)
    answer_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(answer_label)
    queue_redraw()

func configure(index: int, text_value: String) -> void:
    answer_index = index
    answer_text = text_value
    if answer_label != null:
        answer_label.text = answer_text
    queue_redraw()

func set_highlighted(value: bool) -> void:
    highlighted = value
    queue_redraw()

func set_enabled(value: bool) -> void:
    enabled = value

func _draw() -> void:
    var outer := Color(1.0, 0.85, 0.25) if highlighted else Color(0.07, 0.38, 0.18)
    var inner := Color(0.24, 0.69, 0.31) if highlighted else Color(0.18, 0.58, 0.25)
    draw_circle(Vector2.ZERO, 76, outer)
    draw_circle(Vector2.ZERO, 68, inner)
    draw_colored_polygon(PackedVector2Array([
        Vector2(0, 0), Vector2(74, -18), Vector2(72, 18)
    ]), Color(0.16, 0.49, 0.22))
    if highlighted:
        draw_arc(Vector2.ZERO, 88, 0, TAU, 48, Color(1.0, 0.92, 0.42), 6)
    draw_circle(Vector2(-42, -35), 8, Color(0.95, 0.45, 0.60))
    draw_circle(Vector2(-32, -40), 8, Color(1.0, 0.72, 0.80))
    draw_circle(Vector2(-35, -29), 8, Color(1.0, 0.82, 0.88))

func _input_event(_viewport, event, _shape_idx) -> void:
    if enabled and event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
        selected.emit(answer_index)
