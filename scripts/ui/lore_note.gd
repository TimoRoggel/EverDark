extends TextureRect

@export_group("Paper Backgrounds")
@export var bg_small: Texture2D
@export var bg_medium: Texture2D
@export var bg_large: Texture2D

@onready var title: Label = %title
@onready var text: Label = %text
@onready var image: TextureRect = %image

func set_note(note: Note) -> void:
	title.text = note.display_name
	text.text = note.text
	
	var length = note.text.length()
	
	if length < 5:
		texture = bg_small
	elif length < 30:
		texture = bg_medium
	else:
		texture = bg_large
	image.texture = note.image
	if note.image:
		image.visible = true
	else:
		image.visible = false
