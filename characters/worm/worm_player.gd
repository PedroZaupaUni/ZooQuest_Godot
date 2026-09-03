extends CharacterBody2D

const SPEED := 285.0
var enabled: bool = true
var wiggle_time: float = 0.0

func _ready() -> void:
    add_to_group("worm_player")
    collision_layer = 1
    collision_mask = 0
    var collision := CollisionShape2D.new()
    var shape := CapsuleShape2D.new()
    shape.radius = 22.0
    shape.height = 62.0
    collision.shape = shape
    collision.rotation = PI * 0.5
    add_child(collision)
    queue_redraw()

func _physics_process(delta: float) -> void:
    wiggle_time += delta
    if not enabled:
        velocity = Vector2.ZERO
        queue_redraw()
        return
    var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
    if Input.is_physical_key_pressed(KEY_A):
        direction.x -= 1.0
    if Input.is_physical_key_pressed(KEY_D):
        direction.x += 1.0
    if Input.is_physical_key_pressed(KEY_W):
        direction.y -= 1.0
    if Input.is_physical_key_pressed(KEY_S):
        direction.y += 1.0
    direction = direction.normalized()
    velocity = direction * SPEED
    move_and_slide()
    position.x = clamp(position.x, 55.0, 1225.0)
    position.y = clamp(position.y, 250.0, 625.0)
    if direction.length() > 0.1:
        rotation = lerp_angle(rotation, direction.angle(), 12.0 * delta)
    queue_redraw()

func reset_to(start_position: Vector2) -> void:
    position = start_position
    velocity = Vector2.ZERO
    rotation = 0.0
    modulate = Color.WHITE
    enabled = true

func celebrate() -> void:
    enabled = false
    var tween := create_tween()
    tween.tween_property(self, "scale", Vector2(1.25, 0.80), 0.12)
    tween.tween_property(self, "scale", Vector2(0.90, 1.20), 0.12)
    tween.tween_property(self, "scale", Vector2.ONE, 0.16)
    await tween.finished

func _draw() -> void:
    var pink := Color(0.86, 0.35, 0.39)
    for i in range(5):
        var x := float(i - 2) * 19.0
        var y := sin(wiggle_time * 8.0 + float(i)) * 5.0
        draw_circle(Vector2(x, y), 18, pink.lightened(float(i) * 0.02))
    draw_circle(Vector2(38, sin(wiggle_time * 8.0 + 4.0) * 5.0 - 5), 4, Color.WHITE)
    draw_circle(Vector2(39, sin(wiggle_time * 8.0 + 4.0) * 5.0 - 5), 2, Color(0.16, 0.08, 0.08))
