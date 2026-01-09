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

	clear_page(l_paper, l_text)
	clear_page(r_paper, r_text)

	var idx_left = current_pair_index * 2
	if idx_left < all_notes.size():
		setup_page(l_paper, l_text, all_notes[idx_left])
	
	var idx_right = idx_left + 1
	if idx_right < all_notes.size():
		setup_page(r_paper, r_text, all_notes[idx_right])

func clear_page(paper: TextureRect, text: Label):
	if paper: 
		paper.visible = false
		var mat = paper.material as ShaderMaterial
		if mat: mat.set_shader_parameter("unlock_progress", 1.0)
	if text: 
		text.text = ""
		text.modulate.a = 1.0

func setup_page(paper: TextureRect, text: Label, note: Note):
	if not paper or not text: return
	
	paper.visible = true
	var mat = paper.material as ShaderMaterial
	var is_unlocked = LoreSystem.unlocked_notes.has(note.id)
	
	var length = note.text.length()
	if length < 10: paper.texture = bg_small
	elif length < 60: paper.texture = bg_medium
	else: paper.texture = bg_large
		
	if mat: mat.set_shader_parameter("has_image", true)
	
	if is_unlocked:
		text.text = note.text
	else:
		text.text = "" 

	if is_unlocked and note.id == note_id_to_animate:
		if mat: mat.set_shader_parameter("unlock_progress", 0.0)
		text.modulate.a = 0.0 
		
		active_tween = create_tween()
		active_tween.set_parallel(true)
		active_tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
		
		if mat: active_tween.tween_property(mat, "shader_parameter/unlock_progress", 1.0, 4.0)
		active_tween.tween_property(text, "modulate:a", 1.0, 3.0)
		
		note_id_to_animate = -1

	elif is_unlocked:
		if mat: mat.set_shader_parameter("unlock_progress", 1.0)
		text.modulate.a = 1.0

	else:
		if mat: mat.set_shader_parameter("unlock_progress", 0.0)
		text.modulate.a = 0.0

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
