extends CheckBox


func _on_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)
