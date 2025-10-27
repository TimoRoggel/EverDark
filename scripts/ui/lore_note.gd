extends TextureRect

@onready var title: Label = %title
@onready var text: Label = %text
@onready var image: TextureRect = %image

func set_note(note: Note) -> void:
	title.text = note.display_name
	text.text = note.text
	image.texture = note.image
