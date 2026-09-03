extends Node2D

const UI := preload("res://shared/ui_helpers.gd")
const LANE_Y := [285.0, 420.0, 555.0]

var option_labels: Array = []
var options: Array = ["A", "B", "C"]
var selected_lane: int = 1

func _ready() -> void:
    for i in range(3):
        var label := UI.make_label(str(options[i]), 23, Color.WHITE)
        label.position = Vector2(-92, LANE_Y[i] - 38)
        label.size = Vector2(184, 76)
        label.add_theme_stylebox_override("normal", UI.make_panel_style(Color(0.05, 0.23, 0.34, 0.94), Color(0.95, 0.77, 0.24), 16, 3))
        add_child(label)
        option_labels.append(label)
    queue_redraw()

func set_options(new_options: Array) -> void:
    options = new_options.duplicate(true)
    for i in range(min(3, option_labels.size())):
        option_labels[i].text = str(options[i])
    queue_redraw()

func set_selected_lane(index: int) -> void:
    selected_lane = clamp(index, 0, 2)
    for i in range(option_labels.size()):
        var background := Color(0.11, 0.48, 0.62, 0.97) if i == selected_lane else Color(0.05, 0.23, 0.34, 0.94)
        var border := Color(1.0, 0.90, 0.38) if i == selected_lane else Color(0.45, 0.72, 0.78)
        option_labels[i].add_theme_stylebox_override("normal", UI.make_panel_style(background, border, 16, 4 if i == selected_lane else 2))

func _draw() -> void:
    var wall := Color(0.22, 0.18, 0.15)
    draw_rect(Rect2(-55, 155, 110, 58), wall)
    draw_rect(Rect2(-55, 627, 110, 93), wall)
    draw_rect(Rect2(-55, 342, 110, 20), wall)
    draw_rect(Rect2(-55, 477, 110, 20), wall)
    for y in [175.0, 352.0, 487.0, 660.0]:
        draw_circle(Vector2(0, y), 16, Color(0.35, 0.28, 0.20))
