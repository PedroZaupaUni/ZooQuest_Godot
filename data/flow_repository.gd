extends Node

const FLOW_PATH := "res://data/story_flow.json"
var steps: Array = []
var load_error: String = ""

func _ready() -> void:
    _load_flow()

func _load_flow() -> void:
    if not FileAccess.file_exists(FLOW_PATH):
        load_error = "Arquivo de fluxo nao encontrado: " + FLOW_PATH
        push_error(load_error)
        return
    var file := FileAccess.open(FLOW_PATH, FileAccess.READ)
    if file == null:
        load_error = "Nao foi possivel abrir o fluxo narrativo."
        push_error(load_error)
        return
    var parsed = JSON.parse_string(file.get_as_text())
    if typeof(parsed) != TYPE_ARRAY:
        load_error = "O arquivo de fluxo possui JSON invalido."
        push_error(load_error)
        return
    steps = parsed

func get_steps() -> Array:
    return steps.duplicate(true)

func is_ready_for_game() -> bool:
    return load_error.is_empty() and not steps.is_empty()
