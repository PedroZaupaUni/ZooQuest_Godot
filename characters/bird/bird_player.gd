extends Node2D


const BIRD_TEXTURE := preload("res://assets/icons/bird_icon_lateral.svg")
const ICON_SIZE := Vector2(118, 118)
const ICON_OFFSET := Vector2(2, 0)


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
	var wing_tilt := sin(flap_time * 10.0) * 0.05
	draw_set_transform(ICON_OFFSET, wing_tilt, Vector2.ONE)
	var rect := Rect2(-ICON_SIZE * 0.5, ICON_SIZE)
	draw_texture_rect(BIRD_TEXTURE, rect, false)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	 
