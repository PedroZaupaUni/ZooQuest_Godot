extends Node

const SFX := {
    "click": preload("res://assets/audio/sfx/click.wav"),
    "correct": preload("res://assets/audio/sfx/correct.wav"),
    "wrong": preload("res://assets/audio/sfx/wrong.wav"),
    "transform": preload("res://assets/audio/sfx/transform.wav"),
    "finish": preload("res://assets/audio/sfx/finish.wav")
}

func play_sfx(sound_name: String, volume_db: float = -5.0) -> void:
    if not SFX.has(sound_name):
        return
    var player := AudioStreamPlayer.new()
    player.stream = SFX[sound_name]
    player.volume_db = volume_db
    add_child(player)
    player.finished.connect(player.queue_free)
    player.play()

func stop_all_sfx() -> void:
    # Teardown deterministico para troca de contexto/testes. No gameplay normal,
    # cada player continua sendo liberado pelo sinal finished.
    for child in get_children():
        if child is AudioStreamPlayer:
            var player: AudioStreamPlayer = child as AudioStreamPlayer
            player.stop()
            if not player.is_queued_for_deletion():
                player.queue_free()

func active_sfx_count() -> int:
    var count: int = 0
    for child in get_children():
        if child is AudioStreamPlayer and not child.is_queued_for_deletion():
            count += 1
    return count
