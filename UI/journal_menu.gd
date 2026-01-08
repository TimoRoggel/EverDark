extends Control

@onready var menu_layer = $BookBackground/Menu_Layer
@onready var tutorial_layer = $BookBackground/Tutorial_Layer
@onready var notes_layer = $BookBackground/Notes_layer

func _ready():
	LoreSystem.screen = self
	
	tutorial_layer.back_requested.connect(show_menu)
	if notes_layer.has_signal("back_requested"):
		notes_layer.back_requested.connect(show_menu)
	
	show_menu()
	visible = false

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("pause"):
		if notes_layer.visible or tutorial_layer.visible:
			show_menu()
			get_viewport().set_input_as_handled()
		
		elif menu_layer.visible:
			_close_book()
			get_viewport().set_input_as_handled()

func load_note(note: Note, _set_selected: bool = false):
	visible = true
	get_tree().paused = true 
	
	_on_btn_notes_pressed()
	
	if notes_layer.has_method("load_note"):
		notes_layer.load_note(note)

func show_menu():
	menu_layer.visible = true
	tutorial_layer.visible = false
	notes_layer.visible = false

func _on_btn_tutorial_pressed():
	menu_layer.visible = false
	notes_layer.visible = false
	tutorial_layer.visible = true
	if tutorial_layer.has_method("open_tutorial"):
		tutorial_layer.open_tutorial()

func _on_btn_notes_pressed():
	menu_layer.visible = false
	tutorial_layer.visible = false
	notes_layer.visible = true

func _on_btn_back_to_menu_pressed():
	show_menu()

func _close_book():
	visible = false
	get_tree().paused = false 

func _on_button_pressed() -> void:
	_close_book()
