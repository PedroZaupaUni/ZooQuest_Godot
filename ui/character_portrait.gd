extends Control

var form_name: String = "human"
var accent_color: Color = Color(0.27, 0.72, 0.43)
var pulse: float = 0.0
var animated: bool = false

func configure(new_form: String, new_color: Color, use_animation: bool = false) -> void:
    form_name = new_form
    accent_color = new_color
    animated = use_animation
    queue_redraw()

func _process(delta: float) -> void:
    if animated:
        pulse += delta
        queue_redraw()

func _draw() -> void:
    var center := size * 0.5
    var bob := sin(pulse * 3.0) * 5.0 if animated else 0.0
    center.y += bob
    draw_circle(center, min(size.x, size.y) * 0.42, Color(1, 1, 1, 0.12))
    match form_name:
        "frog":
            _draw_frog(center)
        "bird":
            _draw_bird(center)
        "worm":
            _draw_worm(center)
        _:
            _draw_human(center)

func _draw_human(center: Vector2) -> void:
    var skin := Color(0.96, 0.76, 0.55)
    draw_circle(center + Vector2(0, -48), 25, skin)
    draw_circle(center + Vector2(-8, -52), 3, Color(0.12, 0.16, 0.20))
    draw_circle(center + Vector2(8, -52), 3, Color(0.12, 0.16, 0.20))
    draw_arc(center + Vector2(0, -44), 9, 0.2, PI - 0.2, 20, Color(0.25, 0.12, 0.10), 3)
    draw_rect(Rect2(center + Vector2(-28, -20), Vector2(56, 75)), accent_color, true)
    draw_line(center + Vector2(-20, -5), center + Vector2(-52, 30), skin, 10)
    draw_line(center + Vector2(20, -5), center + Vector2(52, 30), skin, 10)
    draw_line(center + Vector2(-14, 52), center + Vector2(-25, 92), Color(0.15, 0.24, 0.48), 13)
    draw_line(center + Vector2(14, 52), center + Vector2(25, 92), Color(0.15, 0.24, 0.48), 13)

func _draw_frog(center: Vector2) -> void:
    var green := accent_color
    draw_circle(center + Vector2(-28, -38), 23, green.lightened(0.12))
    draw_circle(center + Vector2(28, -38), 23, green.lightened(0.12))
    draw_circle(center, 58, green)
    draw_circle(center + Vector2(-29, -42), 7, Color.WHITE)
    draw_circle(center + Vector2(29, -42), 7, Color.WHITE)
    draw_circle(center + Vector2(-29, -42), 3, Color(0.08, 0.16, 0.12))
    draw_circle(center + Vector2(29, -42), 3, Color(0.08, 0.16, 0.12))
    draw_arc(center + Vector2(0, 4), 27, 0.25, PI - 0.25, 28, Color(0.08, 0.25, 0.15), 4)
    draw_circle(center + Vector2(-58, 45), 24, green.darkened(0.08))
    draw_circle(center + Vector2(58, 45), 24, green.darkened(0.08))

func _draw_bird(center: Vector2) -> void:
    var body := accent_color
    draw_circle(center, 52, body)
    draw_circle(center + Vector2(38, -32), 31, body.lightened(0.08))
    draw_colored_polygon(PackedVector2Array([
        center + Vector2(65, -35), center + Vector2(94, -23), center + Vector2(65, -10)
    ]), Color(1.0, 0.72, 0.18))
    draw_colored_polygon(PackedVector2Array([
        center + Vector2(-18, 4), center + Vector2(-88, -35), center + Vector2(-48, 38)
    ]), body.darkened(0.12))
    draw_circle(center + Vector2(47, -39), 6, Color.WHITE)
    draw_circle(center + Vector2(49, -39), 3, Color(0.08, 0.12, 0.18))
    draw_line(center + Vector2(-6, 46), center + Vector2(-8, 72), Color(0.42, 0.25, 0.10), 4)
    draw_line(center + Vector2(15, 46), center + Vector2(18, 72), Color(0.42, 0.25, 0.10), 4)

func _draw_worm(center: Vector2) -> void:
    var segment := accent_color
    for i in range(6):
        var p := center + Vector2((i - 2.5) * 28.0, sin(float(i) * 1.3) * 14.0)
        draw_circle(p, 23, segment.lightened(float(i) * 0.025))
    var head := center + Vector2(82, sin(5.0 * 1.3) * 14.0)
    draw_circle(head + Vector2(5, -5), 4, Color.WHITE)
    draw_circle(head + Vector2(6, -5), 2, Color(0.12, 0.08, 0.08))
    draw_arc(head + Vector2(5, 5), 8, 0.2, PI - 0.2, 14, Color(0.28, 0.08, 0.08), 2)
