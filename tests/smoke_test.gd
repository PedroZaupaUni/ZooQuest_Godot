extends SceneTree

const SCENES := [
    "res://core/main.tscn",
    "res://ui/main_menu.tscn",
    "res://ui/narrative_screen.tscn",
    "res://ui/transformation_screen.tscn",
    "res://ui/ending_screen.tscn",
    "res://ui/hud.tscn",
    "res://minigames/frog/frog_minigame.tscn",
    "res://minigames/bird/bird_minigame.tscn",
    "res://minigames/worm/worm_minigame.tscn"
]

func _init() -> void:
    var failures: Array[String] = []
    for scene_path in SCENES:
        var resource = load(scene_path)
        if resource == null:
            failures.append("Falha ao carregar: " + scene_path)
        elif resource is PackedScene:
            var instance = resource.instantiate()
            if instance == null:
                failures.append("Falha ao instanciar: " + scene_path)
            else:
                instance.free()
    if failures.is_empty():
        print("ZOOQUEST_GODOT_SMOKE=PASS")
        quit(0)
    else:
        for failure in failures:
            push_error(failure)
        print("ZOOQUEST_GODOT_SMOKE=FAIL")
        quit(1)
