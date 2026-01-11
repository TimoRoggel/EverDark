class_name Note extends DataDrivenResource

@export var display_name: String = ""
@export_multiline var text: String = ""
@export var image: Texture2D = null

static func from_data(data: Dictionary) -> Note:
	var note: Note = Note.new()
	if data.get("id") != null:
		note.id = data["id"]
	if data.get("name") != null:
		note.display_name = data["name"]
	if data.get("text") != null:
		note.text = data["text"]
	else:
		note.text = ""
	var image_uid = data.get("image")
	if image_uid is String and !image_uid.is_empty():
		note.image = load(image_uid)
	return note
