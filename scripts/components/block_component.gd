class_name BlockComponent extends Component

@export var block_texture: Texture2D = null
@export var block_range: float = 90.0

var input: InputComponent = null
var block_angle: float = 0.0
var block_sprite: Sprite2D = Sprite2D.new()

func _enter() -> void:
	input = controller.get_component(InputComponent)
	
	block_sprite.texture = block_texture
	block_sprite.z_as_relative = false
	block_sprite.y_sort_enabled = false
	block_sprite.z_index = 10
	add_child(block_sprite)

func _update(_delta: float) -> void:
	block_sprite.visible = input.blocking
	if !block_sprite.visible:
		return
	block_sprite.rotation = block_angle

func _exit() -> void:
	pass

func did_block(angle: float) -> bool:
	if !block_sprite.visible:
		return false
	return wrapf(angle - block_angle - PI * 1.25, -PI, PI) >= PI - deg_to_rad(block_range)
