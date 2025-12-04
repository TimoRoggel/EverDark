class_name PlayerSaveObject extends SaveObject

var file_id: int = 0
# Player Data
var trackers: Dictionary = {}

func _init(id: int = 0) -> void:
	file_id = id
	name = "player_"+str(id)

func save_data() -> Dictionary:
	if file_id == SaveSystem.options.active_save_file:
		return get_all_values()
	return {
		"file_id": file_id
	}

func load_data(data: Dictionary) -> void:
	file_id = data.get("file_id", -1)

	if file_id == SaveSystem.options.active_save_file:
		await Engine.get_main_loop().current_scene.ready
		for key: String in trackers.keys():
			load_specific(data, key)

func load_specific(data: Dictionary, key: String) -> void:
	var stored_value: String = data.get(key, "")
	var stored_data: Variant = trackers[key]["default"] if stored_value.is_empty() else bytes_to_var(str_to_var(stored_value))
	trackers[key]["setter"].call(stored_data)

func clean_data() -> void:
	if file_id == SaveSystem.options.active_save_file:
		for key: String in trackers.keys():
			trackers[key]["setter"].call(trackers[key]["default"])

func get_all_values() -> Dictionary:
	var data: Dictionary = {"file_id": file_id}
	for key: String in trackers.keys():
		if !trackers.has(key):
			continue
		var callable: Callable = trackers[key]["getter"]
		if !callable.is_valid():
			continue
		if callable.is_null():
			continue
		if callable.get_object() == null:
			continue
		data[key] = var_to_bytes(callable.call())
	return data

func duplicate() -> PlayerSaveObject:
	var object: PlayerSaveObject = PlayerSaveObject.new()
	object.load_data(self.save_data())
	return object
