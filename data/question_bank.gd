extends Node
 
const QUESTIONS_PATH := "res://data/questions.json"
var questions_by_phase: Dictionary = {}
var load_error: String = ""
 
func _ready() -> void:
	_load_questions()
 
func _load_questions() -> void:
	if not FileAccess.file_exists(QUESTIONS_PATH):
		load_error = "Arquivo de perguntas nao encontrado: " + QUESTIONS_PATH
		push_error(load_error)
		return
	var file := FileAccess.open(QUESTIONS_PATH, FileAccess.READ)
	if file == null:
		load_error = "Nao foi possivel abrir o arquivo de perguntas."
		push_error(load_error)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		load_error = "O arquivo de perguntas possui JSON invalido."
		push_error(load_error)
		return
	questions_by_phase = parsed
 
func get_questions(phase_id: String) -> Array:
	if not questions_by_phase.has(phase_id):
		push_error("Fase sem perguntas cadastradas: " + phase_id)
		return []
	var questions: Array = questions_by_phase[phase_id].duplicate(true)
	for question in questions:
		shuffle_options(question)
	return questions
 

func shuffle_options(question: Dictionary) -> void:
	var options: Array = question.get("options", [])
	if options.size() <= 1:
		return
	var correct_index: int = int(question.get("correct_index", 0))
	var order: Array = range(options.size())
	order.shuffle()
	var shuffled_options: Array = []
	var new_correct_index := 0
	for new_pos in range(order.size()):
		var original_pos: int = order[new_pos]
		shuffled_options.append(options[original_pos])
		if original_pos == correct_index:
			new_correct_index = new_pos
	question["options"] = shuffled_options
	question["correct_index"] = new_correct_index
 
func is_ready_for_game() -> bool:
	return load_error.is_empty() and questions_by_phase.size() >= 3
