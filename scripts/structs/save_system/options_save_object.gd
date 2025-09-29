class_name OptionsSaveObject extends SaveObject

# Misc.
var active_save_file: int = 0
# Audio Settings
var master_volume: float = 0.5
var sound_volume: float = 1.0
var music_volume: float = 0.5

func _init() -> void:
	name = "options"

func save_data() -> Dictionary:
	return {
		"active_save_file": active_save_file,
		"master_volume": master_volume,
		"sound_volume": sound_volume,
		"music_volume": music_volume
	}

func load_data(data: Dictionary) -> void:
	active_save_file = data.get("active_save_file", 0)
	master_volume = data.get("master_volume", 0.5)
	sound_volume = data.get("sound_volume", 1.0)
	music_volume = data.get("music_volume", 0.5)

func clean_data() -> void:
	active_save_file = 0
	master_volume = 0.5
	sound_volume = 1.0
	music_volume = 0.5

func duplicate() -> OptionsSaveObject:
	var object: OptionsSaveObject = OptionsSaveObject.new()
	object.load_data(self.save_data())
	return object
