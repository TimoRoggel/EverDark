class_name PauseMenu extends Control

@onready var pause_sound: RandomAudioStreamPlayer2D = %pause_sound
@onready var resume_sound: RandomAudioStreamPlayer2D = %resume_sound

func _ready() -> void:
	UIManager.pause_menu = self
	hide()

func _on_resume_pressed() -> void:
	UIManager.toggle_pause()

func _on_options_pressed() -> void:
	UIManager.settings_menu.show()
	hide()

func _on_quit_pressed() -> void:
	get_tree().quit()
