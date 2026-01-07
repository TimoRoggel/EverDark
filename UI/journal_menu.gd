extends Control

@onready var menu_layer = $BookBackground/Menu_Layer
@onready var tutorial_layer = $BookBackground/Tutorial_Layer
@onready var notes_layer = $BookBackground/Notes_layer

func _ready():
	tutorial_layer.back_requested.connect(show_menu)
	
	show_menu()

func show_menu():
	menu_layer.visible = true
	tutorial_layer.visible = false
	notes_layer.visible = false

func _on_btn_tutorial_pressed():
	menu_layer.visible = false
	notes_layer.visible = false
	tutorial_layer.open_tutorial()

func _on_btn_notes_pressed():
	menu_layer.visible = false
	tutorial_layer.visible = false
	notes_layer.visible = true

func _on_btn_back_to_menu_pressed():
	show_menu()

func _on_button_pressed() -> void:
	visible = false
