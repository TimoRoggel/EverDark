class_name PauseMenu extends Control

@onready var settings_pause_menu: Control = $SettingsPauseMenu
@onready var buttons: VBoxContainer = $MarginContainer/Buttons
@onready var journal_menu: Control = $JournalMenu

var is_paused: bool = false
var unique_id: int = ResourceUID.create_id()

func _ready() -> void:
	GameManager.ui_opened_conditions[name + str(unique_id)] = func() -> bool: return visible
	
	visible = false
	settings_pause_menu.visible = false
	journal_menu.visible = false
	buttons.visible = true
	
	if journal_menu.has_signal("back_requested"):
		journal_menu.back_requested.connect(_on_journal_back_to_pause)

func _exit_tree() -> void:
	GameManager.ui_opened_conditions.erase(name + str(unique_id))

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause"):
		
		if visible and settings_pause_menu.visible:
			_on_settings_pause_menu_exit_settings_pause_menu()
			get_viewport().set_input_as_handled()
			return

		if visible and journal_menu.visible:
			_on_journal_back_to_pause()
			get_viewport().set_input_as_handled()
			return

		if not is_paused and GameManager.try_close_active_ui():
			get_viewport().set_input_as_handled()
			return

		_toggle_pause()
		get_viewport().set_input_as_handled()
		
	if event.is_action_pressed("toggle_inventory"):
		if GameManager.ui_open and GameManager.player.inventory.container.visible and !GameManager.is_chest_open:
			GameManager.player.get_tree().paused = false
	if event.is_action_pressed("interact") and GameManager.is_chest_open:
		if GameManager.ui_open:
			GameManager.player.get_tree().paused = false

func _toggle_pause() -> void:
	if is_paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	if GameManager.active_ui_node != null:
		return
		
	GameManager.paused = true
	get_tree().paused = true
	visible = true
	is_paused = true
	
	buttons.visible = true
	settings_pause_menu.visible = false
	journal_menu.visible = false

func _resume() -> void:
	GameManager.paused = false
	get_tree().paused = false
	visible = false
	is_paused = false

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
	SaveSystem.reset()
	get_tree().paused = false  
	SceneTransitionController.change_scene("res://UI/Main menu/main_menu.tscn", "fade_layer", 1.0)

func _on_journal_pressed() -> void:
	buttons.visible = false
	journal_menu.visible = true
	
	if journal_menu.has_method("show_menu"):
		journal_menu.show_menu()
	elif journal_menu.has_method("open_notes"):
		journal_menu.open_notes()

func _on_journal_back_to_pause() -> void:
	journal_menu.visible = false
	buttons.visible = true
