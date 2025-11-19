class_name EverdarkComputeComponent extends Component

const OFFSET: Vector2 = Vector2(160.0, 160.0)

var everdark_material: ShaderMaterial = null
var camera: Camera2D = null

func _enter() -> void:
	everdark_material = load("uid://dpfoqgjxxik6t")
	camera = controller.get_component(CameraComponent).camera
	everdark_material.set_shader_parameter("lumin_circle_start", Generator.LUMIN_SIZE)
	everdark_material.set_shader_parameter("lumin_circle_end", Generator.LUMIN_SIZE + 16.0)
	updates_in_physics = false

func _update(_delta: float) -> void:
	var lumin_transforms: Array = get_lumin_transforms()
	everdark_material.set_shader_parameter("lumin_positions", lumin_transforms.map(func(t: Array) -> Vector2: return t[0]))
	#everdark_material.set_shader_parameter("lumin_sizes", lumin_transforms.map(func(t: Array) -> float: return t[1]))
	everdark_material.set_shader_parameter("lumin_count", min(64, Generator.lumin_positions.size()))
	everdark_material.set_shader_parameter("player_position", Debug.to_screen(global_position) + OFFSET)

func _exit() -> void:
	pass

func get_lumin_transforms() -> Array:
	var transforms: Array = []
	var positions: Array = []
	positions.append_array(Generator.lumin_positions)
	var sizes: PackedFloat32Array = []
	sizes.append(Generator.LUMIN_SIZE * 2.0)
	
	for i: int in positions.size():
		var pos: Vector2 = positions[i]
		var size: float = Generator.LUMIN_SIZE
		if sizes.size() > i:
			size = sizes[i]
		transforms.append([pos, size])
	
	transforms.sort_custom(func(a: Array, b: Array) -> bool:
		return a[0].distance_squared_to(camera.global_position) < b[0].distance_squared_to(camera.global_position)
	)
	transforms = transforms.map(func(a: Array) -> Array: return [Debug.to_screen(a[0]) + OFFSET, a[1]])

	while transforms.size() < 64:
		transforms.append([Vector2.ZERO, 0.0])
	transforms.resize(64)
	
	return transforms
