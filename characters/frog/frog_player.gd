extends Node2D

var body_color: Color = Color(0.35, 0.76, 0.29)
var is_busy: bool = false

func _ready() -> void:
    queue_redraw()

func _draw() -> void:
    draw_circle(Vector2(-20, -25), 16, body_color.lightened(0.14))
    draw_circle(Vector2(20, -25), 16, body_color.lightened(0.14))
    draw_circle(Vector2.ZERO, 36, body_color)
    draw_circle(Vector2(-20, -27), 5, Color.WHITE)
    draw_circle(Vector2(20, -27), 5, Color.WHITE)
    draw_circle(Vector2(-20, -27), 2.5, Color(0.05, 0.12, 0.08))
    draw_circle(Vector2(20, -27), 2.5, Color(0.05, 0.12, 0.08))
    draw_arc(Vector2(0, 2), 17, 0.2, PI - 0.2, 20, Color(0.06, 0.24, 0.13), 3)
    draw_circle(Vector2(-39, 25), 15, body_color.darkened(0.08))
    draw_circle(Vector2(39, 25), 15, body_color.darkened(0.08))

func reset_to(start_position: Vector2) -> void:
    position = start_position
    scale = Vector2.ONE
    modulate = Color.WHITE
    rotation = 0.0
    is_busy = false

func jump_to(target_position: Vector2, correct: bool) -> void:
    if is_busy:
        return
    is_busy = true
    var origin := position
    var midpoint := (origin + target_position) * 0.5 + Vector2(0, -150)
    var tween := create_tween()
    tween.set_trans(Tween.TRANS_QUAD)
    tween.set_ease(Tween.EASE_OUT)
    tween.tween_property(self, "position", midpoint, 0.30)
    tween.set_ease(Tween.EASE_IN)
    tween.tween_property(self, "position", target_position, 0.30)
    await tween.finished
    if correct:
        var celebrate := create_tween()
        celebrate.tween_property(self, "scale", Vector2(1.25, 0.85), 0.12)
        celebrate.tween_property(self, "scale", Vector2.ONE, 0.18)
        await celebrate.finished
    else:
        var sink := create_tween()
        sink.set_parallel(true)
        sink.tween_property(self, "position", target_position + Vector2(0, 95), 0.45)
        sink.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.45)
        sink.tween_property(self, "rotation", 0.8, 0.45)
        await sink.finished
