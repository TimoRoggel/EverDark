class_name BlockComponent extends Component

const BLOCK_STREAM: AudioStream = preload("uid://c7h318jhm6e5q")

@export var block_texture: Texture2D = null
@export var block_range: float = 90.0

var input: InputComponent = null
var block_angle: float = 0.0
var block_sprite: Sprite2D = Sprite2D.new()
var block_sound: RandomAudioStreamPlayer2D = null
var block_alignment: float = (block_range / 180.0) - 1.0

func _enter() -> void:
	input = controller.get_component(InputComponent)
	
	block_sprite.texture = block_texture
	block_sprite.z_as_relative = false
	block_sprite.y_sort_enabled = false
	block_sprite.z_index = 10
	add_child(block_sprite)
	
	block_sound = GameManager.create_audio_player(&"SFX", [BLOCK_STREAM], self)

func _update(_delta: float) -> void:
	block_sprite.visible = input.blocking
	if !block_sprite.visible:
		return
	block_sprite.rotation = block_angle

func _exit() -> void:
	pass

func did_block(target_position: Vector2) -> bool:
	if !block_sprite.visible:
		return false
	var distance_to_target: float = global_position.distance_to(target_position)
	if distance_to_target > 16.0:
		var attack_direction: Vector2 = global_position.direction_to(target_position)
		var block_direction: Vector2 = Vector2.from_angle(block_angle)
		var alignment: float = block_direction.dot(attack_direction)
		#Debug.add_line("block", Vector2.ZERO, block_direction * 40.0, Color.BLUE, 1.0, 2.0, true)
		#Debug.add_line("attack", Vector2.ZERO, attack_direction * 40.0, Color.RED, 1.0, 2.0, true)
		if alignment > block_alignment:
			return false
	block_sound.play_randomized()
	return true
