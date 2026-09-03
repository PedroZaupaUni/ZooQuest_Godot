extends Node

signal score_changed(new_score: int)
signal statistics_changed(correct: int, wrong: int)

var score: int = 0
var correct_answers: int = 0
var wrong_answers: int = 0
var current_phase: String = "menu"

func reset_game() -> void:
    score = 0
    correct_answers = 0
    wrong_answers = 0
    current_phase = "intro"
    score_changed.emit(score)
    statistics_changed.emit(correct_answers, wrong_answers)

func register_correct(points: int = 10) -> void:
    correct_answers += 1
    score += points
    score_changed.emit(score)
    statistics_changed.emit(correct_answers, wrong_answers)

func register_wrong() -> void:
    wrong_answers += 1
    statistics_changed.emit(correct_answers, wrong_answers)

func set_phase(phase_id: String) -> void:
    current_phase = phase_id
