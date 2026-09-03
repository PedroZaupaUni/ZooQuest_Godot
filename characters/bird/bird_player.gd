extends Node2D

const LANE_Y := [285.0, 420.0, 555.0]

var current_lane: int = 1
var target_y: float = LANE_Y[1]
var enabled: bool = true
var flap_time: float = 0.0

func _ready() -> void:
    position = Vector2(235, target_y)
    queue_redraw()

func _process(delta: float) -> void:
    flap_time += delta
    position.y = move_toward(position.y, target_y, 520.0 * delta)
    queue_redraw()

func set_lane(index: int) -> void:
    current_lane = clamp(index, 0, 2)
    target_y = LANE_Y[current_lane]

func reset_player() -> void:
    enabled = true
    set_lane(1)
    position = Vector2(235, LANE_Y[1])
    rotation = 0.0
    modulate = Color.WHITE
    scale = Vector2.ONE

func play_collision() -> void:
    enabled = false
    var original := position
    var tween := create_tween()
    tween.tween_property(self, "position", original + Vector2(-24, -10), 0.08)
    tween.tween_property(self, "position", original + Vector2(18, 12), 0.08)
    tween.tween_property(self, "position", original + Vector2(-14, 8), 0.08)
    tween.tween_property(self, "position", original, 0.08)
    await tween.finished

func play_celebration() -> void:
    enabled = false
    var tween := create_tween()
    tween.tween_property(self, "rotation", -0.28, 0.12)
    tween.tween_property(self, "rotation", 0.28, 0.18)
    tween.tween_property(self, "rotation", 0.0, 0.12)
    await tween.finished

func _draw() -> void:
    var blue := Color(0.20, 0.55, 0.88)
    var flap := sin(flap_time * 10.0) * 12.0
    draw_circle(Vector2.ZERO, 30, blue)
    draw_circle(Vector2(24, -17), 19, blue.lightened(0.08))
    draw_colored_polygon(PackedVector2Array([Vector2(40, -17), Vector2(62, -8), Vector2(40, 1)]), Color(1.0, 0.70, 0.16))
    draw_colored_polygon(PackedVector2Array([Vector2(-5, 2), Vector2(-58, -20 - flap), Vector2(-32, 28)]), blue.darkened(0.12))
    draw_circle(Vector2(29, -22), 4.5, Color.WHITE)
    draw_circle(Vector2(30, -22), 2, Color(0.07, 0.10, 0.14))
    draw_line(Vector2(-20, 24), Vector2(-28, 43), Color(0.43, 0.25, 0.10), 3)
    draw_line(Vector2(0, 28), Vector2(4, 45), Color(0.43, 0.25, 0.10), 3)
