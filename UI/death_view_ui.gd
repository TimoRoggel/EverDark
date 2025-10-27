extends Control

signal respawn_pressed
signal menu_pressed

func _on_respawn_btn_pressed() -> void:
	respawn_pressed.emit()
	print("Respawn!")

func _on_menu_btn_pressed() -> void:
	menu_pressed.emit()
	print("To the main menu!")
