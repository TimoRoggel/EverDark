extends Control

signal back_requested

@onready var pages_container: Control = $PagesContainer
@onready var btn_back_to_menu: Button = $NavButtons/Btn_BackToMenu
@onready var btn_prev: Button = $NavButtons/Btn_Prev
@onready var btn_next: Button = $NavButtons/Btn_Next

var pages: Array = []
var current_index: int = 0

func _ready():
	pages = pages_container.get_children()
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_next.pressed.connect(_on_next_pressed)
	btn_back_to_menu.pressed.connect(_on_back_menu_pressed)

func open_tutorial():
	visible = true
	current_index = 0
	update_display()

func update_display():
	for i in range(pages.size()):
		pages[i].visible = (i == current_index)
	
	if current_index == 0:
		btn_back_to_menu.visible = true
		btn_prev.visible = false
	else:
		btn_back_to_menu.visible = false
		btn_prev.visible = true
	
	if current_index == pages.size() - 1:
		btn_next.visible = false
	else:
		btn_next.visible = true

func _on_back_menu_pressed():
	back_requested.emit()

func _on_next_pressed() -> void:
	if current_index < pages.size() - 1:
		current_index += 1
		update_display()

func _on_prev_pressed() -> void:
	if current_index > 0:
		current_index -= 1
		update_display()
