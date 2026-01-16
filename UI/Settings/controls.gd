extends TabBar

@onready var input_button_scene = preload("res://UI/Settings/input_button.tscn")
@onready var action_list: VBoxContainer = $MarginContainer/ScrollContainer/ActionList

var is_remapping: bool = false 
var action_to_remap: StringName = &""
var remapping_button: Button = null 

var input_groups: Dictionary = {
	"MOVEMENT": {
		"up": "Move Up",
		"down": "Move Down",
		"left": "Move Left",
		"right": "Move Right",
		"dash": "Sprint"
	},
	"COMBAT": {
		"attack": "Attack",
		"block": "Block"
	},
	"INTERACTIONS": {
		"interact": "Interact",
		"drop_item": "Drop Item",
		"toggle_inventory": "Open Inventory"
	},
	"UI": {
		"pause": "Pause Game"
	}
}

func _ready() -> void:
	_create_action_list()

func _create_action_list() -> void: 
	InputMap.load_from_project_settings()
	
	for item: Node in action_list.get_children():
		item.queue_free()
	
	for group_name: String in input_groups:
		_create_category_header(group_name)
		
		var actions_in_group: Dictionary = input_groups[group_name]
		
		for action: String in actions_in_group:
			var line_item: Control = input_button_scene.instantiate()
			var action_label: Label = line_item.find_child("LabelAction")
			var input_button: Button = line_item.find_child("RemapButton") 
			
			action_label.text = actions_in_group[action]
			
			var events: Array[InputEvent] = InputMap.action_get_events(action)
			if events.size() > 0:
				input_button.text = events[0].as_text().trim_suffix(" (Physical)")
			else:
				input_button.text = "Unbound"
			
			action_list.add_child(line_item)
			input_button.pressed.connect(_on_input_button_pressed.bind(input_button, action))

func _create_category_header(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	var settings = LabelSettings.new()
	label.label_settings = settings
	action_list.add_child(label)

func _on_input_button_pressed(button: Button, action: String) -> void:
	if !is_remapping: 
		is_remapping = true 
		action_to_remap = action 
		remapping_button = button
		button.text = "Press key..."

func _input(event: InputEvent) -> void:
	if is_remapping:
		if (
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
	button.text = event.as_text().trim_suffix(" (Physical)")

func _on_back_to_def_pressed() -> void:
	_create_action_list()
