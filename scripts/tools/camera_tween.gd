class_name CameraTween extends RefCounted

var tween: Tween = null
var amount: float = 0.0
var duration: float = 0.0
var start_time: int = 0

static func get_score(_amount: float, _remaining_time: float) -> float:
	return _amount * 3 + _remaining_time

func _init(_tween: Tween, _amount: float, _duration: float) -> void:
	tween = _tween
	amount = _amount
	duration = _duration
	start_time = Time.get_ticks_msec()

func passed_time() -> float:
	return (Time.get_ticks_msec() - start_time) / 1000.0

func remaining_time() -> float:
	return duration - passed_time()

func end() -> void:
	tween.stop()
	tween.finished.emit()
