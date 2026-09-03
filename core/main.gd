extends Node

const MainMenuScene := preload("res://ui/main_menu.tscn")
const NarrativeScene := preload("res://ui/narrative_screen.tscn")
const TransformationScene := preload("res://ui/transformation_screen.tscn")
const EndingScene := preload("res://ui/ending_screen.tscn")
const FrogScene := preload("res://minigames/frog/frog_minigame.tscn")
const BirdScene := preload("res://minigames/bird/bird_minigame.tscn")
const WormScene := preload("res://minigames/worm/worm_minigame.tscn")

@onready var stage_host: Node = $StageHost

var flow_steps: Array = []
var flow_index: int = -1
var current_stage: Node = null

func _ready() -> void:
    flow_steps = FlowRepository.get_steps()
    if not QuestionBank.is_ready_for_game() or not FlowRepository.is_ready_for_game():
        _show_fatal_error()
        return
    _show_menu()

func _show_menu() -> void:
    GameState.set_phase("menu")
    var stage = MainMenuScene.instantiate()
    stage.start_requested.connect(_start_game)
    _mount_stage(stage)

func _start_game() -> void:
    AudioManager.play_sfx("click")
    GameState.reset_game()
    flow_steps = FlowRepository.get_steps()
    flow_index = -1
    _advance_flow()

func _advance_flow() -> void:
    flow_index += 1
    if flow_index >= flow_steps.size():
        _show_menu()
        return
    var step: Dictionary = flow_steps[flow_index]
    var kind: String = str(step.get("kind", ""))
    match kind:
        "narrative":
            _show_narrative(step)
        "transformation":
            _show_transformation(step)
        "minigame":
            _show_minigame(str(step.get("phase", "")))
        "ending":
            _show_ending()
        _:
            push_error("Etapa desconhecida no fluxo: " + kind)
            _advance_flow()

func _show_narrative(step: Dictionary) -> void:
    GameState.set_phase(str(step.get("id", "narrative")))
    var stage = NarrativeScene.instantiate()
    stage.configure(
        str(step.get("title", "ZooQuest")),
        step.get("pages", []),
        str(step.get("speaker", "Narrador"))
    )
    stage.finished.connect(_advance_flow)
    stage.menu_requested.connect(_return_to_menu)
    _mount_stage(stage)

func _show_transformation(step: Dictionary) -> void:
    GameState.set_phase(str(step.get("id", "transformation")))
    var stage = TransformationScene.instantiate()
    stage.configure(
        str(step.get("from", "human")),
        str(step.get("to", "human")),
        str(step.get("title", "Transformacao")),
        str(step.get("text", ""))
    )
    stage.finished.connect(_advance_flow)
    stage.menu_requested.connect(_return_to_menu)
    _mount_stage(stage)

func _show_minigame(phase_id: String) -> void:
    GameState.set_phase(phase_id)
    var stage
    match phase_id:
        "frog":
            stage = FrogScene.instantiate()
        "bird":
            stage = BirdScene.instantiate()
        "worm":
            stage = WormScene.instantiate()
        _:
            push_error("Mini-game desconhecido: " + phase_id)
            _advance_flow()
            return
    stage.completed.connect(_advance_flow)
    stage.menu_requested.connect(_return_to_menu)
    _mount_stage(stage)

func _show_ending() -> void:
    GameState.set_phase("ending")
    var stage = EndingScene.instantiate()
    stage.replay_requested.connect(_start_game)
    stage.menu_requested.connect(_return_to_menu)
    _mount_stage(stage)

func _return_to_menu() -> void:
    AudioManager.play_sfx("click")
    flow_index = -1
    _show_menu()

func _mount_stage(stage: Node) -> void:
    if current_stage != null and is_instance_valid(current_stage):
        stage_host.remove_child(current_stage)
        current_stage.queue_free()
    current_stage = stage
    stage_host.add_child(stage)

func _show_fatal_error() -> void:
    var label := Label.new()
    label.text = "Nao foi possivel carregar os dados locais do ZooQuest.\nVerifique data/questions.json e data/story_flow.json."
    label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size", 30)
    label.anchor_right = 1.0
    label.anchor_bottom = 1.0
    stage_host.add_child(label)
