extends Control

@export var square_bg: Texture2D
@export var wide_bg: Texture2D

@onready var action_lbl: Label = $HBoxContainer/actionlbl

@onready var single_key: TextureRect = $HBoxContainer/keyicon
@onready var single_key_lbl: Label = $HBoxContainer/keyicon/keylbl

@onready var wasd_group: VBoxContainer = $HBoxContainer/WASD_group

const SQUARE_SIZE = Vector2(48, 32) 
const WIDE_SIZE = Vector2(64, 32)

var steps = [
	{"action_check": ["up", "down", "left", "right"], "text": "WASD", "title": "Move"},
	{"action_check": "dash", "text": "Shift", "title": "Sprint"},
	{"action_check": "open", "text": "E", "title": "Open Inventory"},
	{"action_check": "attack", "text": "LMB", "title": "Attack"},
	{"action_check": "block", "text": "RMB", "title": "Block"},
	{"action_check": "interact", "text": "F", "title": "Use/Harvest"},
	{"action_check": "drop_item", "text": "Q", "title": "Drop"},
	{"action_check": "attack", "text": "LMB", "title": "Eat"},
	{"action_check": "pause", "text": "Esc", "title": "Pause/Exit"}
]

var current_idx = 0
var is_active = false

func _ready():
	show_step()

func show_step():
	if current_idx >= steps.size():
		queue_free()
		return
		
	var step = steps[current_idx]
	action_lbl.text = step.title
	
	if step.text == "WASD":
		single_key.visible = false
		wasd_group.visible = true
	else:
		wasd_group.visible = false
		single_key.visible = true
		
		single_key_lbl.text = step.text
		
		if step.text.length() > 1:
			single_key.texture = wide_bg
			single_key.custom_minimum_size = WIDE_SIZE
			single_key.size = WIDE_SIZE
		else:
			single_key.texture = square_bg
			single_key.custom_minimum_size = SQUARE_SIZE
			single_key.size = SQUARE_SIZE
		
	visible = true
	is_active = true

func _input(_event):
	if not is_active: return
	
	var step = steps[current_idx]
	var pressed = false
	
	if step.action_check is Array:
		for action in step.action_check:
			if Input.is_action_just_pressed(action):
				pressed = true
				break
	else:
		if Input.is_action_just_pressed(step.action_check):
			pressed = true
			
	if pressed:
		complete_step()

func complete_step():
	is_active = false
	
	var target_node = single_key
	if wasd_group.visible:
		target_node = wasd_group

	var tween = create_tween()
	tween.tween_property(target_node, "modulate", Color(2, 2, 2), 0.1)
	tween.tween_property(target_node, "modulate", Color(1, 1, 1), 0.3)
	
	await get_tree().create_timer(2.5).timeout
	
	visible = false
	current_idx += 1
	show_step()
