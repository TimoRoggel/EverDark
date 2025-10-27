extends Control

@onready var exit: Button = $MarginContainer/VBoxContainer/Exit as Button

signal exit_settings_pause_menu

func _ready() -> void:
	
	set_process(false)

func _on_exit_pressed() -> void:
	exit_settings_pause_menu.emit()
	set_process(false)
