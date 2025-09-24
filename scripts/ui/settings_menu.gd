class_name SettingsMenu extends SoundTabContainer

@onready var settings: Dictionary[String, Control] = {
	"master_volume": %master_volume_slider,
	"sounds_volume": %sounds_volume_slider,
	"ui_volume": %ui_volume_slider
}

func _ready() -> void:
	UIManager.settings_menu = self
	load_volume_slider("master_volume")
	load_volume_slider("sounds_volume")
	load_volume_slider("ui_volume")
	hide()
	super()

func load_volume_slider(key: String) -> void:
	var slider: SoundHSlider = settings[key]
	slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index(slider.bus))

func _on_reset_pressed() -> void:
	print("reset")

func _on_close_pressed() -> void:
	hide()
	UIManager.pause_menu.show()

func _on_master_volume_slider_value_changed(value: float) -> void:
	SettingsManager.change_volume(0, value)

func _on_sounds_volume_slider_value_changed(value: float) -> void:
	SettingsManager.change_volume(1, value)

func _on_ui_volume_slider_value_changed(value: float) -> void:
	SettingsManager.change_volume(2, value)
