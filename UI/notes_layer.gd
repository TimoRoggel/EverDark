extends Control

signal back_requested

@export_group("Paper Backgrounds")
@export var bg_small: Texture2D
@export var bg_medium: Texture2D
@export var bg_large: Texture2D

@onready var l_text: Label = $"LeftPage_Visuals/Content text"
@onready var l_paper: TextureRect = $LeftPage_Visuals/PaperImage
@onready var r_text: Label = $"RightPage_Visuals/Content text"
@onready var r_paper: TextureRect = $RightPage_Visuals/PaperImage

@onready var btn_prev: Button = $NavButtons/Btn_Prev
@onready var btn_next: Button = $NavButtons/Btn_Next
@onready var btn_back: Button = $NavButtons/Btn_BackToMenu

var all_notes: Array = [] 
var current_pair_index: int = 0

func _ready():
	load_notes()
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_next.pressed.connect(_on_next_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	visibility_changed.connect(_on_visibility_changed)
	update_display() 
func _on_visibility_changed():
	if visible:
		update_display()

func load_notes():
	all_notes.clear()
	var id = 0
	while true:
		var note = DataManager.get_resource_by_id("notes", id)
		if note:
			all_notes.append(note)
			id += 1
		else:
			break 

func open_notes():
	visible = true
	current_pair_index = 0
	update_display()

func update_display():
	clear_page(l_paper, l_text)
	clear_page(r_paper, r_text)

	var idx_left = current_pair_index * 2
	if idx_left < all_notes.size():
		setup_page(l_paper, l_text, all_notes[idx_left])
	
	var idx_right = idx_left + 1
	if idx_right < all_notes.size():
		setup_page(r_paper, r_text, all_notes[idx_right])

	btn_back.visible = (current_pair_index == 0)
	btn_prev.visible = (current_pair_index > 0)
	
	var max_visible_idx = (current_pair_index * 2) + 1
	btn_next.visible = (max_visible_idx < all_notes.size() - 1)

func clear_page(paper: TextureRect, text: Label):
	paper.visible = false
	text.text = ""
func setup_page(paper: TextureRect, text: Label, note: Note):
	paper.visible = true
	var is_unlocked = LoreSystem.unlocked_notes.has(note.id)
	var mat = paper.material as ShaderMaterial
	var length = note.text.length()
	if length < 5:
		paper.texture = bg_small
	elif length < 30:
		paper.texture = bg_medium
	else:
		paper.texture = bg_large
	if is_unlocked:
		text.text = note.text
	else:
		text.text = "" 
	if mat:
		mat.set_shader_parameter("is_locked", !is_unlocked)
		mat.set_shader_parameter("has_image", true)

func _on_back_pressed():
	back_requested.emit()

func _on_next_pressed():
	current_pair_index += 1
	update_display()

func _on_prev_pressed():
	current_pair_index -= 1
	update_display()
