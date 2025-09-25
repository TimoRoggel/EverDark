class_name SoundButton extends Button

#const UI_BUTTON: AudioStream = preload("res://audio/sounds/ui/ui_button.wav")
#const UI_BUTTON_HOVER: AudioStream = preload("res://audio/sounds/ui/ui_button_hover.wav")

var pressed_sound: AudioStreamPlayer = null
var hover_sound: AudioStreamPlayer = null

func _ready() -> void:
	pressed_sound = AudioStreamPlayer.new()
	pressed_sound.bus = &"ui"
	#pressed_sound.stream = UI_BUTTON
	hover_sound = AudioStreamPlayer.new()
	hover_sound.bus = &"ui"
	#hover_sound.stream = UI_BUTTON_HOVER
	add_child(pressed_sound)
	add_child(hover_sound)
	pressed.connect(func() -> void: pressed_sound.play())
	mouse_entered.connect(func() -> void: hover_sound.play())
	focus_entered.connect(func() -> void: hover_sound.play())
