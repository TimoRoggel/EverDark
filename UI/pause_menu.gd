class_name PauseMenu extends Control
@onready var options: Panel = $Options
@onready var buttons: VBoxContainer = $PauseMenu/Buttons
@onready var control_panel: Panel = $"Control panel"
@onready var audio_panel: Panel = $"Audio panel"
@onready var graphics_panel: Panel = $"Graphics panel"
var paused: bool = false

func _ready() -> void:
	visible = false
	get_tree().paused = false
	buttons.visible = true
	options.visible = false 
	graphics_panel.visible = false 
	audio_panel.visible = false 
	control_panel.visible = false  

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		_toggle_pause()

func _toggle_pause() -> void:
	if paused:
		_resume()
	else:
		_pause()

func _pause() -> void:
	get_tree().paused = true
	visible = true
	paused = true

func _resume() -> void:
	get_tree().paused = false
	visible = false
	paused = false

func _on_quit_pressed() -> void:
	pass

func _on_resume_pressed() -> void:
	_resume()

func _on_options_pressed() -> void:
	buttons.visible = false
	options.visible = true 

func _on_back_pressed() -> void:
	buttons.visible = true
	options.visible = false 

func _on_controls_pressed() -> void:
	buttons.visible = false
	options.visible = false
	graphics_panel.visible = false 
	audio_panel.visible = false 
	control_panel.visible = true 
	

func _on_graphics_pressed() -> void:
	buttons.visible = false
	options.visible = false
	graphics_panel.visible = true 
	audio_panel.visible = false 
	control_panel.visible = false  


func _on_audio_pressed() -> void:
	buttons.visible = false
	options.visible = false
	graphics_panel.visible = false 
	audio_panel.visible = true 
	control_panel.visible = false  
	
func _on_back_c_pressed() -> void:
	buttons.visible = false
	options.visible = true 
	graphics_panel.visible = false 
	audio_panel.visible = false 
	control_panel.visible = false 
