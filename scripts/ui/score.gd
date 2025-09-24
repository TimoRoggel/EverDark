class_name Score extends Label

func _ready() -> void:
	ScoreManager.score_changed.connect(on_score_changed)
	set_score(ScoreManager.score)

func on_score_changed(old_score: int, new_score: int) -> void:
	var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_EXPO)
	tween.tween_method(func(s: int) -> void: set_score(s), old_score, new_score, 0.25)

func set_score(score: float) -> void:
	text = str(int(floor(score)))
