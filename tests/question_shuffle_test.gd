extends Node

func _ready() -> void:
    call_deferred("_run_test")

func _fail(message: String) -> void:
    push_error(message)
    print("ZOOQUEST_QUESTION_SHUFFLE_TEST=FAIL")
    print("ZOOQUEST_QUESTION_SHUFFLE_TEARDOWN=PASS")
    get_tree().quit(1)

func _run_test() -> void:
    var expected_sorted: Array = ["A", "B", "C"]
    expected_sorted.sort()

    for _iteration in range(64):
        var question := {
            "options": ["A", "B", "C"],
            "correct_index": 1,
        }
        QuestionBank.shuffle_options(question)

        var options: Array = question["options"]
        if options.size() != 3:
            _fail("Shuffle alterou a quantidade de alternativas.")
            return

        var sorted_options: Array = options.duplicate(true)
        sorted_options.sort()
        if sorted_options != expected_sorted:
            _fail("Shuffle alterou o conjunto de alternativas.")
            return

        var correct_index: int = int(question["correct_index"])
        if correct_index < 0 or correct_index >= options.size():
            _fail("Shuffle produziu correct_index fora dos limites.")
            return

        if options[correct_index] != "B":
            _fail("Shuffle perdeu a associacao com a resposta correta.")
            return

    print("ZOOQUEST_QUESTION_SHUFFLE_TEST=PASS")
    print("ZOOQUEST_QUESTION_SHUFFLE_TEARDOWN=PASS")
    get_tree().quit(0)
