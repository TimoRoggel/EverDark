extends TabBar
@onready var input_button_scene =preload("res://UI/Settings/input_button.tscn")
@onready var action_list: VBoxContainer = $MarginContainer/ScrollContainer/ActionList


var is_remapping: bool = false 
var action_to_remap: StringName = &""
var remapping_button: Button = null 

var input_actions: Dictionary[String, String] = {
	"up": "Move up",
	"down": "Move down",
	"left": "Move left",
	"right": "Move right",
	"pause": "Pause menu",
	"attack": "Attack",
	"block": "Block",
	"dash": "Dash",
	"toggle_inventory": "Open inventory",
	"interact": "Interact",
}

func _ready() -> void:
	_create_action_list()

func _create_action_list() -> void: 
	InputMap.load_from_project_settings()
	for item: Node in action_list.get_children():
		item.queue_free()
	
	for action: String in input_actions:
		var button: Button = input_button_scene.instantiate()
		var action_label: Label = button.find_child("LabelAction")
		var input_label: Label = button.find_child("LabelInput")
		
		action_label.text = input_actions[action]
		
		var events: Array[InputEvent] = InputMap.action_get_events(action)
		if events.size() > 0:
			input_label.text = events[0].as_text().trim_suffix(" (Physical)")
		else:
			input_label.text = ""
		
		action_list.add_child(button)
		button.pressed.connect(_on_input_button_pressed.bind(button, action))

func _on_input_button_pressed(button: Button, action: String) -> void:
	if !is_remapping: 
		is_remapping = true 
		action_to_remap = action 
		remapping_button = button
		button.find_child("LabelInput").text = "Press key to bind..."

func _input(event: InputEvent) -> void:
	if is_remapping:
		if(
			event is InputEventKey || 
			event is InputEventMouseButton && event.pressed 
		):
			
			if event is InputEventMouseButton && event.double_click:
				event.double_click = false 
			
			InputMap.action_erase_events(action_to_remap)
			InputMap.action_add_event(action_to_remap, event)
			_update_action_list(remapping_button, event)
			
			is_remapping = false
			action_to_remap = &""
			remapping_button = null 
			
			accept_event()

func _update_action_list(button: Button, event: InputEvent) -> void:
	button.find_child("LabelInput").text = event.as_text().trim_suffix(" (Physical)")

func _on_back_to_def_pressed() -> void:
	_create_action_list()
