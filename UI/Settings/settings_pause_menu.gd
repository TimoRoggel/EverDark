extends Control

@onready var exit: Button = $MarginContainer/VBoxContainer/Exit as Button

var unique_id: int = ResourceUID.create_id()

signal exit_settings_pause_menu

func _ready() -> void:
	GameManager.ui_opened_conditions[name + str(unique_id)] = func() -> bool: return visible
	set_process(false)

func _exit_tree() -> void:
	GameManager.ui_opened_conditions.erase(name + str(unique_id))

func _on_exit_pressed() -> void:
	exit_settings_pause_menu.emit()
	set_process(false)
