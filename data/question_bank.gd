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
    return questions_by_phase[phase_id].duplicate(true)

func is_ready_for_game() -> bool:
    return load_error.is_empty() and questions_by_phase.size() >= 3
