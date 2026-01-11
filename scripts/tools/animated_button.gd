class_name AnimatedButton extends Button

const SHADER: Shader = preload("uid://cm8gcrxu7aw5b")
const BUTTON_HOVER_STREAM: AudioStream = preload("uid://dqdpykh1igsme")
const BUTTON_PRESS_STREAM: AudioStream = preload("uid://bjxm2sfj74q4q")

@export var muted: bool = false

@onready var hover_player: AudioStreamPlayer =  GameManager.create_audio_player_basic(&"SFX", BUTTON_HOVER_STREAM, 0.25, self)
@onready var click_player: AudioStreamPlayer = GameManager.create_audio_player_basic(&"SFX", BUTTON_PRESS_STREAM, 0.25, self)

func _ready() -> void:
	pressed.connect(_click)
	focus_entered.connect(_hover)
	mouse_entered.connect(_hover)
	material = create_material()

func _click() -> void:
	if !muted:
		click_player.play()
	zoom(0.5)

func _hover() -> void:
	if muted:
		return
	if !click_player.playing:
		hover_player.play()
	zoom()

func create_material() -> ShaderMaterial:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = SHADER
	mat.set_shader_parameter("pivot", size * 0.5)
	mat.set_shader_parameter("scale", 1.0)
	mat.set_shader_parameter("pixel_size", Vector2.ONE / size)
	return mat

func zoom(amount: float = 1.2) -> void:
	var old_z: int = 0
	var should_z_swap: bool = z_index == 999
	if should_z_swap:
		old_z = z_index
		z_index = 999
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_method(set_shader_scale, 1.0, amount, 0.05)
	tween.tween_method(set_shader_scale, amount, 1.0, 0.2)
	tween.play()
	await tween.finished
	if should_z_swap:
		z_index = old_z

func set_shader_scale(shader_scale: float) -> void:
	material.set_shader_parameter("scale", shader_scale)
