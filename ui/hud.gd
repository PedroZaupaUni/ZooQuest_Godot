extends CanvasLayer

signal menu_requested

const UI := preload("res://shared/ui_helpers.gd")

var phase_label: Label
var score_label: Label
var progress_label: Label
var question_label: Label
var feedback_panel: Panel
var feedback_label: Label
var instructions_label: Label

func _ready() -> void:
	_build_interface()
	GameState.score_changed.connect(_on_score_changed)
	_on_score_changed(GameState.score)

func _build_interface() -> void:
	var root := Control.new()
	root.anchor_right = 1.0
	root.anchor_bottom = 1.0
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(root)

	var top_panel := Panel.new()
	top_panel.position = Vector2(20, 16)
	top_panel.size = Vector2(1240, 128)
	top_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	top_panel.add_theme_stylebox_override("panel", UI.make_panel_style(Color(0.035, 0.13, 0.12, 0.94), Color(0.96, 0.80, 0.28), 20, 3))
	root.add_child(top_panel)

	phase_label = UI.make_label("Fase", 22, Color(0.98, 0.84, 0.34))
	phase_label.position = Vector2(28, 12)
	phase_label.size = Vector2(280, 36)
	phase_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_panel.add_child(phase_label)

	progress_label = UI.make_label("Desafio 1/3", 18, Color(0.82, 0.95, 0.90))
	progress_label.position = Vector2(28, 52)
	progress_label.size = Vector2(250, 32)
	progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	top_panel.add_child(progress_label)

	score_label = UI.make_label("Pontos: 0", 22, Color.WHITE)
	score_label.position = Vector2(930, 12)
	score_label.size = Vector2(180, 36)
	score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	top_panel.add_child(score_label)

	question_label = UI.make_label("Pergunta", 27, Color.WHITE)
	question_label.position = Vector2(295, 18)
	question_label.size = Vector2(650, 90)
	top_panel.add_child(question_label)

	var menu_button := UI.make_button("MENU", Vector2(105, 48), Color(0.28, 0.38, 0.44))
	menu_button.position = Vector2(1110, 42)
	menu_button.mouse_filter = Control.MOUSE_FILTER_STOP
	menu_button.pressed.connect(_on_menu_pressed)
	top_panel.add_child(menu_button)

	instructions_label = UI.make_label("", 18, Color.WHITE)
	instructions_label.position = Vector2(205, 657)
	instructions_label.size = Vector2(870, 38)
	root.add_child(instructions_label)

	feedback_panel = Panel.new()
	feedback_panel.position = Vector2(330, 154)
	feedback_panel.size = Vector2(620, 74)
	feedback_panel.visible = false
	feedback_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(feedback_panel)

	feedback_label = UI.make_label("", 23, Color.WHITE)
	feedback_label.position = Vector2(20, 8)
	feedback_label.size = Vector2(580, 58)
	feedback_panel.add_child(feedback_label)

func configure(phase_name: String, instructions: String) -> void:
	phase_label.text = phase_name
	instructions_label.text = instructions

func set_question(question: String, current: int, total: int) -> void:
	question_label.text = question
	progress_label.text = "Desafio %d/%d" % [current, total]

func show_feedback(message: String, is_correct: bool) -> void:
	feedback_panel.visible = true
	var background := Color(0.08, 0.48, 0.26, 0.97) if is_correct else Color(0.72, 0.22, 0.17, 0.97)
	var border := Color(0.55, 1.0, 0.65) if is_correct else Color(1.0, 0.70, 0.50)
	feedback_panel.add_theme_stylebox_override("panel", UI.make_panel_style(background, border, 18, 3))
	feedback_label.text = message

func hide_feedback() -> void:
	feedback_panel.visible = false
	feedback_label.text = ""

func _on_score_changed(new_score: int) -> void:
	if score_label != null:
		score_label.text = "Pontos: %d" % new_score

func _on_menu_pressed() -> void:
	menu_requested.emit()
