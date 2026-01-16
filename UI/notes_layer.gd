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
@onready var nav_buttons_container: Control = $NavButtons

@onready var paper_image_small_l: TextureRect = $LeftPage_Visuals/PaperImage_Small_L
@onready var content_text_small_l: Label = $"LeftPage_Visuals/Content text_Small_L"
@onready var paper_image_small_r: TextureRect = $RightPage_Visuals/PaperImage_Small_R
@onready var content_text_small_r: Label = $"RightPage_Visuals/Content text_Small_R"

var all_notes: Array = [] 
var current_pair_index: int = 0
var note_id_to_animate: int = -1
var active_tween: Tween

func _ready():
	LoreSystem.screen = self
	
	load_notes_data()
	
	btn_prev.pressed.connect(_on_prev_pressed)
	btn_next.pressed.connect(_on_next_pressed)
	btn_back.pressed.connect(_on_back_pressed)
	
	visibility_changed.connect(_on_visibility_changed)
	visible = false

func load_note(note: Note, _set_selected: bool = false) -> void:
	load_notes_data() 
	
	var target_index = -1
	for i in range(all_notes.size()):
		if all_notes[i].id == note.id:
			target_index = i
			break
	
	if target_index != -1:
		current_pair_index = floori(target_index / 2.0)
		note_id_to_animate = note.id
	
	open_notes()

func _on_visibility_changed():
	if visible:
		if not is_instance_valid(get_tree()) or not get_tree().paused:
			note_id_to_animate = -1
		update_display()
	else:
		if active_tween and active_tween.is_valid():
			active_tween.kill()

func load_notes_data():
	all_notes.clear()
	for id in range(200): 
		var note = DataManager.get_resource_by_id("notes", id)
		if note:
			all_notes.append(note)
		else:
			break 

func open_notes():
	visible = true
	if not l_paper: return 
	update_display()

func update_display():
	if active_tween and active_tween.is_valid():
		active_tween.kill()

	if nav_buttons_container: nav_buttons_container.visible = true
	
	if current_pair_index == 0:
		if btn_back: btn_back.visible = true
		if btn_prev: btn_prev.visible = false
	else:
		if btn_back: btn_back.visible = false
		if btn_prev: btn_prev.visible = true
	
	if btn_next:
		var next_page_start_idx = (current_pair_index + 1) * 2
		btn_next.visible = (next_page_start_idx < all_notes.size())

	clear_page(l_paper, l_text, paper_image_small_l, content_text_small_l)
	clear_page(r_paper, r_text, paper_image_small_r, content_text_small_r)

	var idx_left = current_pair_index * 2
	if idx_left < all_notes.size():
		setup_page(l_paper, l_text, paper_image_small_l, content_text_small_l, all_notes[idx_left])
	
	var idx_right = idx_left + 1
	if idx_right < all_notes.size():
		setup_page(r_paper, r_text, paper_image_small_r, content_text_small_r, all_notes[idx_right])

func clear_page(normal_paper: TextureRect, normal_text: Label, small_paper: TextureRect, small_text: Label):
	if normal_paper: 
		normal_paper.visible = false
		var mat = normal_paper.material as ShaderMaterial
		if mat: mat.set_shader_parameter("unlock_progress", 1.0)
	if normal_text: 
		normal_text.text = ""
		normal_text.modulate.a = 1.0
		
	if small_paper:
		small_paper.visible = false
		var mat = small_paper.material as ShaderMaterial
		if mat: mat.set_shader_parameter("unlock_progress", 1.0)
	if small_text:
		small_text.text = ""
		small_text.modulate.a = 1.0

func setup_page(normal_paper: TextureRect, normal_text: Label, small_paper: TextureRect, small_text: Label, note: Note):
	var target_paper: TextureRect
	var target_text: Label
	var length = note.text.length()
	
	if length < 10:
		target_paper = small_paper
		target_text = small_text
		target_paper.texture = bg_small
	else:
		target_paper = normal_paper
		target_text = normal_text
		if length < 60:
			target_paper.texture = bg_medium
		else:
			target_paper.texture = bg_large

	if not target_paper or not target_text: return

	target_paper.visible = true
	
	var mat = target_paper.material as ShaderMaterial
	if mat: mat.set_shader_parameter("has_image", true)

	var is_unlocked = LoreSystem.unlocked_notes.has(note.id)
	
	if is_unlocked:
		target_text.text = note.text
	else:
		target_text.text = "" 

	if is_unlocked and note.id == note_id_to_animate:
		if mat: mat.set_shader_parameter("unlock_progress", 0.0)
		target_text.modulate.a = 0.0 
		
		active_tween = create_tween()
		active_tween.set_parallel(true)
		active_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		if mat: active_tween.tween_property(mat, "shader_parameter/unlock_progress", 1.0, 4.0)
		active_tween.tween_property(target_text, "modulate:a", 1.0, 3.0)
		
		note_id_to_animate = -1

	elif is_unlocked:
		if mat: mat.set_shader_parameter("unlock_progress", 1.0)
		target_text.modulate.a = 1.0

	else:
		if mat: mat.set_shader_parameter("unlock_progress", 0.0)
		target_text.modulate.a = 0.0

func _on_back_pressed():
	visible = false
	back_requested.emit()

func _on_next_pressed():
	var next_page_start_idx = (current_pair_index + 1) * 2
	if next_page_start_idx < all_notes.size():
		current_pair_index += 1
		update_display()

func _on_prev_pressed():
	if current_pair_index > 0:
		current_pair_index -= 1
		update_display()
