extends Control
 
signal start_requested
 
const UI := preload("res://shared/ui_helpers.gd")
const Portrait := preload("res://ui/character_portrait.gd")
const TREE_TEXTURE := preload("res://assets/icons/tree_icon.svg")
const TREE_SIZE := Vector2(300, 300) # arte quadrada (viewBox 512x512)
 
var instructions_panel: Panel
 
func _ready() -> void:
	set_process(false)
	_build_interface()
	queue_redraw()
 
func _draw() -> void:
	draw_rect(Rect2(Vector2.ZERO, Vector2(1280, 720)), Color(0.58, 0.86, 0.98))
	draw_circle(Vector2(1070, 105), 62, Color(1.0, 0.88, 0.36))
	for cloud in [Vector2(170, 115), Vector2(470, 85), Vector2(895, 155)]:
		draw_circle(cloud, 38, Color(1, 1, 1, 0.88))
		draw_circle(cloud + Vector2(42, 8), 31, Color(1, 1, 1, 0.88))
		draw_circle(cloud + Vector2(-40, 10), 27, Color(1, 1, 1, 0.88))
	draw_rect(Rect2(0, 535, 1280, 185), Color(0.20, 0.62, 0.32))
	draw_rect(Rect2(0, 610, 1280, 110), Color(0.12, 0.43, 0.25))
	for x in [90, 1170]:
		_draw_tree(x)
 


func _draw_tree(x: float) -> void:
	var ground_y := 572.0
	var rect := Rect2(Vector2(x - TREE_SIZE.x * 0.5, ground_y - TREE_SIZE.y), TREE_SIZE)
	draw_texture_rect(TREE_TEXTURE, rect, false)
 
func _build_interface() -> void:
	var title := UI.make_label("ZOOQUEST", 72, Color(0.08, 0.27, 0.18))
	title.position = Vector2(240, 62)
	title.size = Vector2(800, 90)
	add_child(title)
 
	var subtitle := UI.make_label("A Jornada do Aprendizado", 33, Color(0.12, 0.36, 0.25))
	subtitle.position = Vector2(250, 145)
	subtitle.size = Vector2(780, 50)
	add_child(subtitle)
 
	var tagline := UI.make_label("Matematica, lógica e boas escolhas de forma eficiente e divertida", 22, Color(0.10, 0.28, 0.22))
	tagline.position = Vector2(250, 198)
	tagline.size = Vector2(780, 58)
	add_child(tagline)
 
	var play_button := UI.make_button("JOGAR", Vector2(310, 66), Color(0.12, 0.51, 0.31))
	play_button.position = Vector2(485, 310)
	play_button.pressed.connect(_on_play_pressed)
	add_child(play_button)
	play_button.grab_focus()
 
	var instructions_button := UI.make_button("COMO JOGAR", Vector2(310, 58), Color(0.16, 0.40, 0.62))
	instructions_button.position = Vector2(485, 395)
	instructions_button.pressed.connect(_show_instructions)
	add_child(instructions_button)
 
	var footer := UI.make_label("Educação com qualidade e diversão", 17, Color(1, 1, 1, 0.94))
	footer.position = Vector2(245, 658)
	footer.size = Vector2(790, 36)
	add_child(footer)
 
	_add_portrait("frog", Vector2(235, 430), Color(0.35, 0.76, 0.29))
	_add_portrait("bird", Vector2(875, 405), Color(0.20, 0.55, 0.88))
	_add_portrait("worm", Vector2(760, 520), Color(0.86, 0.35, 0.39))
 
func _add_portrait(form: String, portrait_position: Vector2, color: Color) -> void:
	var portrait = Portrait.new()
	portrait.position = portrait_position
	portrait.size = Vector2(170, 170)
	portrait.configure(form, color, true)
	portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(portrait)
 
func _on_play_pressed() -> void:
	start_requested.emit()
 
func _show_instructions() -> void:
	AudioManager.play_sfx("click")
	if instructions_panel != null and is_instance_valid(instructions_panel):
		return
	instructions_panel = Panel.new()
	instructions_panel.position = Vector2(250, 120)
	instructions_panel.size = Vector2(780, 500)
	instructions_panel.add_theme_stylebox_override("panel", UI.make_panel_style(Color(0.04, 0.14, 0.12, 0.97), Color(0.97, 0.82, 0.30), 24, 4))
	add_child(instructions_panel)
 
	var heading := UI.make_label("Como jogar", 38, Color(1.0, 0.87, 0.35))
	heading.position = Vector2(60, 28)
	heading.size = Vector2(660, 54)
	instructions_panel.add_child(heading)
 
	var body := UI.make_label(
		"Sapo: use esquerda/direita para escolher uma vitoria-regia e ESPACO para pular.\n\n" +
		"Passaro: use cima/baixo para escolher uma passagem antes de chegar ao obstaculo.\n\n" +
		"Minhoca: use as setas ou WASD e encoste na fruta-resposta correta.\n\n" +
		"Em todas as fases, as teclas 1, 2 e 3 tambem selecionam alternativas.",
		22,
		Color.WHITE
	)
	body.position = Vector2(70, 90)
	body.size = Vector2(640, 300)
	body.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	instructions_panel.add_child(body)
 
	var close_button := UI.make_button("ENTENDI", Vector2(220, 55), Color(0.12, 0.51, 0.31))
	close_button.position = Vector2(280, 408)
	close_button.pressed.connect(_close_instructions)
	instructions_panel.add_child(close_button)
	close_button.grab_focus()
 
func _close_instructions() -> void:
	AudioManager.play_sfx("click")
	if instructions_panel != null:
		instructions_panel.queue_free()
		instructions_panel = null
