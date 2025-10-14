class_name MainMenu  extends Control
@onready var start: Button = $HBoxContainer/VBoxContainer/Start
@onready var achievements: Button = $HBoxContainer/VBoxContainer/Achievements
@onready var settings: Button = $HBoxContainer/VBoxContainer/Settings
@onready var exit: Button = $HBoxContainer/VBoxContainer/Exit
@onready var start_level = preload("res://scenes/levels/world.tscn") as PackedScene

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	pass 

func _on_achievements_pressed() -> void:
	pass 
