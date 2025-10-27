class_name SaveManager extends RefCounted

const ENCRYPTION_KEY: String = "20958n080pq89ca3t"

var save_objects: Array[SaveObject] = []

func register_save_data(obj: SaveObject) -> void:
	save_objects.append(obj)

func save_game(file_path: String) -> void:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.WRITE,ENCRYPTION_KEY)
	var save_data: Dictionary = {}
	for obj: SaveObject in save_objects:
		save_data[obj.name] = obj.save_data()
	file.store_string(JSON.stringify(save_data))

func load_game(file_path: String) -> void:
	var file: FileAccess = FileAccess.open_encrypted_with_pass(file_path, FileAccess.READ,ENCRYPTION_KEY)
	if !file:
		# Save data is corrupted
		clean_data()
		return
	var save_data: Dictionary = JSON.parse_string(file.get_as_text())
	for obj: SaveObject in save_objects:
		if (save_data.has(obj.name)):
			obj.load_data(save_data[obj.name])
		else:
			obj.clean_data()

func clean_data() -> void:
	for obj: SaveObject in save_objects:
		obj.clean_data()

func save_file_exists(file_path: String) -> bool:
	return FileAccess.file_exists(file_path)
