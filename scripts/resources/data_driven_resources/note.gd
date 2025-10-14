class_name Note extends DataDrivenResource

@export var display_name: String = ""
@export_multiline var text: String = ""
@export var image: Texture2D = null

static func from_data(data: Dictionary) -> Note:
	var note: Note = Note.new()
	note.id = data["id"]
	note.display_name = data["name"]
	note.text = data["text"]
	var image_uid: String = data.get("image", "")
	if !image_uid.is_empty():
		note.image = load(image_uid)
	return note
