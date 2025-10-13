class_name MainMenu extends Control
@onready var start: Button = $MarginContainer/HBoxContainer/VBoxContainer/Start
@onready var options: Button = $MarginContainer/HBoxContainer/VBoxContainer/Options
@onready var exit: Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit
@onready var start_level = preload("res://scenes/levels/world.tscn") as PackedScene


func _on_options_pressed() -> void:
	pass

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
	
func _on_exit_pressed() -> void:
	get_tree().quit()
