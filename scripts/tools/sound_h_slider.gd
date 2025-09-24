class_name SoundHSlider extends HSlider

#@export var change_sound: AudioStream = preload("res://audio/sounds/ui/ui_slider.wav")
@export var bus: StringName = &"ui"

func _ready() -> void:
	var sound_player: AudioStreamPlayer = AudioStreamPlayer.new()
	sound_player.bus = bus
	#sound_player.stream = change_sound
	add_child(sound_player)
	value_changed.connect(func(_new_value: float) -> void:
		if sound_player.playing:
			return
		sound_player.play()
	)
