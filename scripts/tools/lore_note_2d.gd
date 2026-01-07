@tool
class_name LoreNote2D extends Interactable2D

const TEXTURE: Texture2D = preload("uid://o224qgp07gvy")
const LORE_NOTE_RUNNABLE: GDScript = preload("res://scripts/tools/runnables/lore_note_runnable.gd")

@export var note_id: int = 0

var sprite: Sprite2D = Sprite2D.new()

func _ready() -> void:
	custom_parameter = str("{\"note\": ", note_id, "}")
	interact_script = LORE_NOTE_RUNNABLE
	active = true
	super()
