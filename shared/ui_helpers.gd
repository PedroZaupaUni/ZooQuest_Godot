extends RefCounted

static func color_from_hex(value: String) -> Color:
    return Color.from_string(value, Color.WHITE)

static func make_label(text_value: String, font_size: int, font_color: Color = Color.WHITE) -> Label:
    var label := Label.new()
    label.text = text_value
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    label.add_theme_font_size_override("font_size", font_size)
    label.add_theme_color_override("font_color", font_color)
    return label

static func make_panel_style(background: Color, border: Color, radius: int = 18, border_width: int = 3) -> StyleBoxFlat:
    var style := StyleBoxFlat.new()
    style.bg_color = background
    style.border_color = border
    style.border_width_left = border_width
    style.border_width_top = border_width
    style.border_width_right = border_width
    style.border_width_bottom = border_width
    style.corner_radius_top_left = radius
    style.corner_radius_top_right = radius
    style.corner_radius_bottom_left = radius
    style.corner_radius_bottom_right = radius
    style.content_margin_left = 18.0
    style.content_margin_right = 18.0
    style.content_margin_top = 12.0
    style.content_margin_bottom = 12.0
    return style

static func make_button(text_value: String, button_size: Vector2, accent: Color) -> Button:
    var button := Button.new()
    button.text = text_value
    button.size = button_size
    button.custom_minimum_size = button_size
    button.focus_mode = Control.FOCUS_ALL
    button.add_theme_font_size_override("font_size", 23)
    button.add_theme_color_override("font_color", Color.WHITE)
    button.add_theme_color_override("font_hover_color", Color.WHITE)
    button.add_theme_color_override("font_pressed_color", Color.WHITE)
    button.add_theme_stylebox_override("normal", make_panel_style(accent, accent.lightened(0.18), 15, 2))
    button.add_theme_stylebox_override("hover", make_panel_style(accent.lightened(0.10), Color.WHITE, 15, 3))
    button.add_theme_stylebox_override("pressed", make_panel_style(accent.darkened(0.12), Color.WHITE, 15, 3))
    button.add_theme_stylebox_override("focus", make_panel_style(Color(0, 0, 0, 0), Color(1.0, 0.88, 0.35), 15, 4))
    return button

static func add_full_rect_background(parent: Node, color: Color) -> ColorRect:
    var background := ColorRect.new()
    background.color = color
    background.anchor_right = 1.0
    background.anchor_bottom = 1.0
    background.mouse_filter = Control.MOUSE_FILTER_IGNORE
    parent.add_child(background)
    parent.move_child(background, 0)
    return background
