extends Node

const SFX := {
    "click": preload("res://assets/audio/sfx/click.wav"),
    "correct": preload("res://assets/audio/sfx/correct.wav"),
    "wrong": preload("res://assets/audio/sfx/wrong.wav"),
    "transform": preload("res://assets/audio/sfx/transform.wav"),
    "finish": preload("res://assets/audio/sfx/finish.wav")
}

var sfx_enabled: bool = true

func set_sfx_enabled(enabled: bool) -> void:
    sfx_enabled = enabled
    if not sfx_enabled:
        stop_all_sfx()

func is_sfx_enabled() -> bool:
    return sfx_enabled

func play_sfx(sound_name: String, volume_db: float = -5.0) -> void:
    if not sfx_enabled or not SFX.has(sound_name):
        return

    var player := AudioStreamPlayer.new()
    player.stream = SFX[sound_name]
    player.volume_db = volume_db
    add_child(player)
    player.finished.connect(_on_player_finished.bind(player), CONNECT_ONE_SHOT)
    player.play()

func _on_player_finished(player: AudioStreamPlayer) -> void:
    if player == null or not is_instance_valid(player):
        return

    # Libera a referencia ao AudioStream antes de destruir o player. Isso evita
    # manter playback/resources vivos no encerramento acelerado dos testes.
    player.stop()
    player.stream = null
    if not player.is_queued_for_deletion():
        player.queue_free()

func stop_all_sfx() -> void:
    # Teardown SINCRONO. queue_free() sozinho nao foi suficiente no runner
    # headless: o AudioServer ainda mantinha dois playback resources no shutdown.
    # Removemos a referencia ao stream e destruimos cada player imediatamente.
    var children_snapshot: Array[Node] = []
    for child in get_children():
        if child is AudioStreamPlayer:
            children_snapshot.append(child)

    for child in children_snapshot:
        if child == null or not is_instance_valid(child):
            continue
        var player: AudioStreamPlayer = child as AudioStreamPlayer
        player.stop()
        player.stream = null
        if player.get_parent() == self:
            remove_child(player)
        player.free()

func active_sfx_count() -> int:
    var count: int = 0
    for child in get_children():
        if child is AudioStreamPlayer:
            count += 1
    return count
