extends MarginContainer

const LORE_NOTE: PackedScene = preload("uid://dwv61e2desqha")

@onready var notes_list: ItemList = %notes
@onready var current_note: Control = %current_note

var notes: Array[Note] = []

func _ready() -> void:
	LoreSystem.screen = self
	visibility_changed.connect(_on_visibility_changed)
	notes_list.item_selected.connect(load_note_index)
	hide()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("toggle_notes"):
		visible = !visible
	if !visible:
		return
	if event.is_action_pressed("ui_cancel"):
		hide()

func _on_visibility_changed() -> void:
	get_tree().paused = !get_tree().paused
	if !visible:
		return
	notes_list.clear()
	notes = LoreSystem.get_unlocked_notes()
	if notes.is_empty():
		return
	for note: Note in notes:
		notes_list.add_item(note.display_name)
	notes_list.select(0)
	load_note_index(0)

func load_note_index(index: int) -> void:
	if notes.size() <= index:
		return
	load_note(notes[index])

func load_note(note: Note, set_selected: bool = false) -> void:
	if !note:
		return
	if current_note.get_child_count() > 0:
		current_note.get_child(0).queue_free()
	var scene: Control = LORE_NOTE.instantiate()
	current_note.add_child(scene)
	scene.set_note(note)
	if set_selected:
		for i: int in notes.size():
			if notes[i] == note:
				notes_list.select(i)
				return

func _on_close_pressed() -> void:
	hide()
