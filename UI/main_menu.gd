class_name MainMenu  extends Control
@onready var margin_container: MarginContainer = $MarginContainer
@onready var start: Button = $MarginContainer/HBoxContainer/VBoxContainer/Start
@onready var achievements: Button = $MarginContainer/HBoxContainer/VBoxContainer/Achievements
@onready var settings: Button = $MarginContainer/HBoxContainer/VBoxContainer/Settings
@onready var exit: Button = $MarginContainer/HBoxContainer/VBoxContainer/Exit
@onready var start_level = preload("res://scenes/levels/world.tscn") as PackedScene
@onready var settings_menu: Settings_Menu = $SettingsMenu as Settings_Menu
@onready var margin_container_2: MarginContainer = $MarginContainer2


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(start_level)
	
func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_settings_pressed() -> void:
	margin_container_2.visible = false
	margin_container.visible = false
	settings_menu.set_process(true)
	settings_menu.visible = true 
	
func _on_achievements_pressed() -> void:
	pass 


func _on_settings_menu_exit_settings_menu() -> void:
	margin_container_2.visible = true
	margin_container.visible = true
	settings_menu.visible = false 
