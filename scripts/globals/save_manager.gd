extends Node

const SAVE_FILE_PATH: String = "user://save.file"

var queued_data: Dictionary[String, Variant] = {}
var changes_since_last_save: bool = false

signal save_data_loaded

func _ready() -> void:
	load_data()

func save() -> bool:
	if !changes_since_last_save:
		return false
	changes_since_last_save = false
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if !file:
		return false
	file.store_var(queued_data, true)
	print("saved")
	return true

func save_data() -> void:
	store_content(queued_data, "crosshairs", UIManager.crosshairs)
	store_content(queued_data, "selected_crosshair", UIManager.selected_crosshair)
	store_content(queued_data, "score", ScoreManager.score)
	for bus_idx: int in range(AudioServer.bus_count):
		store_content(queued_data, AudioServer.get_bus_name(bus_idx).to_lower() + "_volume", AudioServer.get_bus_volume_db(bus_idx))

func load_data() -> bool:
	var file: FileAccess = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if !file:
		return false
	var content: Dictionary[String, Variant] = file.get_var(true)
	load_content(content, "crosshairs", func(c: Variant) -> void: UIManager.crosshairs = c)
	load_content(content, "selected_crosshair", func(c: Variant) -> void: UIManager.selected_crosshair = c)
	load_content(content, "score", func(c: Variant) -> void: ScoreManager.score = c)
	for bus_idx: int in range(AudioServer.bus_count):
		load_content(content, AudioServer.get_bus_name(bus_idx).to_lower() + "_volume", func(c: Variant) -> void: AudioServer.set_bus_volume_db(bus_idx, c))
	save_data_loaded.emit()
	return true

func store_content(content: Dictionary[String, Variant], key: String, value: Variant) -> void:
	if content.has(key):
		if content[key] == value:
			return
	content[key] = value
	changes_since_last_save = true

func load_content(content: Dictionary[String, Variant], key: String, method: Callable) -> void:
	if !content.has(key):
		return
	method.call(content[key])
