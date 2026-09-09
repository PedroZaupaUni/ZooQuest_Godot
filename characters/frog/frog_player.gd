extends Node2D

const FROG_TEXTURE := preload("res://assets/icons/frog_icon.svg")
const ICON_SIZE := Vector2(112, 112)
const ICON_OFFSET := Vector2(0, -4)

var body_color: Color = Color(0.35, 0.76, 0.29)
var is_busy: bool = false

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var rect := Rect2(ICON_OFFSET - ICON_SIZE * 0.5, ICON_SIZE)
	draw_texture_rect(FROG_TEXTURE, rect, false, body_color)

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
