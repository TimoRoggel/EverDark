class_name PauseMenu extends Control
@onready var settings_pause_menu: Control = $SettingsPauseMenu
@onready var buttons: VBoxContainer = $MarginContainer/Buttons
var paused: bool = false
var unique_id: int = ResourceUID.create_id()

func _ready() -> void:
	GameManager.ui_opened_conditions[name + str(unique_id)] = func() -> bool: return visible
	visible = false
	get_tree().paused = false
	buttons.visible = true
	settings_pause_menu.visible = false 

func _exit_tree() -> void:
	GameManager.ui_opened_conditions.erase(name + str(unique_id))

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		if settings_pause_menu.visible:
			_on_settings_pause_menu_exit_settings_pause_menu()
		else:
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

func _on_options_pressed() -> void:
	buttons.visible = false
	settings_pause_menu.visible = true 

func _on_settings_pause_menu_exit_settings_pause_menu() -> void:
	buttons.visible = true
	settings_pause_menu.visible = false 

func _on_back_to_main_menu_pressed() -> void:
	get_tree().paused = false  
	var target_scene_path = "res://UI/Main menu/main_menu.tscn"
	SceneTransitionController.change_scene(target_scene_path, "fade_layer", 1.0)
