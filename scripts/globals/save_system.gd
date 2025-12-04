extends Node

const FILE_PATH: String = "user://everdark.sav"
const AUTOSAVE_TIME: float = 2.5
const SAVE_FILES: int = 3

var save_manager: SaveManager = null
var options: OptionsSaveObject = null
var files: Dictionary[int, PlayerSaveObject] = {}

var save_timer: Timer = Timer.new()

signal loaded_data

func _ready() -> void:
	save_manager = SaveManager.new()
	initialize_save_objects()
	add_child(save_timer)
	save_timer.timeout.connect(autosave)
	reset()
	await get_tree().scene_changed
	SaveSystem.start_or_load_game()

func reset() -> void:
	GameManager.ui_opened_conditions = {}
	player().trackers = {}
	Generator.lumin_positions = [Vector2(8,8)]
	save_timer.stop()

func autosave() -> void:
	SaveSystem.save_data()
	save_timer.start(AUTOSAVE_TIME)

func initialize_save_objects() -> void:
	# Options
	options = OptionsSaveObject.new()
	save_manager.register_save_data(options)
	# Save Files (Player)
	for i: int in SAVE_FILES:
		files[i] = PlayerSaveObject.new(i)
		save_manager.register_save_data(files[i])

func start_or_load_game() -> void:
	if save_manager.save_file_exists(FILE_PATH):
		save_manager.load_game(FILE_PATH)
		loaded_data.emit()
	else:
		save_manager.clean_data()
		loaded_data.emit()
	await get_tree().create_timer(AUTOSAVE_TIME).timeout
	autosave()

func save_data() -> void:
	save_manager.save_game(FILE_PATH)

func load_data() -> void:
	save_manager.load_game(FILE_PATH)

func player() -> PlayerSaveObject:
	return files[options.active_save_file]

func track(key: String, getter: Callable, setter: Callable, default: Variant = null) -> void:
	player().trackers[key] = { "getter": getter, "setter": setter, "default": default }
	save_manager.load_data.call_deferred(key)

func untrack(key) -> void:
	player().trackers.erase(key)

func open_savedata_folder() -> void:
	if save_manager.save_file_exists(FILE_PATH):
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path(FILE_PATH))
	else:
		OS.shell_show_in_file_manager(ProjectSettings.globalize_path("user://"))

func delete_data() -> void:
	save_manager.clean_data()
	save_data()
