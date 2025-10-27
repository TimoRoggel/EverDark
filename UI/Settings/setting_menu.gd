class_name Settings_Menu extends Control

@onready var exit: Button = $MarginContainer/VBoxContainer/Exit as Button

signal exit_settings_menu

func _ready() -> void:
	
	set_process(false)

func _on_exit_pressed() -> void:
	exit_settings_menu.emit()
	set_process(false)
