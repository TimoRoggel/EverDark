extends Node

@export var screen: Control = null

var unlocked_notes: PackedInt32Array = []

func _ready() -> void:
	SaveSystem.track("unlocked_notes", func() -> PackedInt32Array: return unlocked_notes, func(_s: PackedInt32Array) -> void: unlocked_notes = _s, [])

func unlock_note(id: int) -> void:
	if unlocked_notes.has(id):
		return
	unlocked_notes.append(id)

func get_unlocked_notes() -> Array[Note]:
	var notes: Array[Note] = []
	for i: int in unlocked_notes:
		notes.append(DataManager.get_resource_by_id("notes", i))
	return notes

func open_screen(note: Note = null) -> void:
	screen.visible = true
	if note:
		screen.load_note(note, true)
