extends Control
class_name PauseMenu

var paused: bool = false

func _ready() -> void:
	visible = false
	get_tree().paused = false


func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	if paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	get_tree().paused = true
	visible = true
	paused = true

func _resume() -> void:
	get_tree().paused = false
	visible = false
	paused = false


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_resume_pressed() -> void:
	_resume()
