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
	everdark_material.set_shader_parameter("lumin_positions", get_local_lumin_positions())
	everdark_material.set_shader_parameter("lumin_count", min(64, Generator.lumin_positions.size()))
	everdark_material.set_shader_parameter("player_position", Debug.to_screen(global_position) + OFFSET)

func _exit() -> void:
	pass

func get_local_lumin_positions() -> PackedVector2Array:
	var positions: Array = []
	positions.append_array(Generator.lumin_positions)
	positions.sort_custom(func(a: Vector2, b: Vector2) -> bool:
		return a.distance_squared_to(camera.global_position) < b.distance_squared_to(camera.global_position)
	)
	positions = positions.map(func(pos: Vector2) -> Vector2: return Debug.to_screen(pos) + OFFSET)
	var shader_positions: PackedVector2Array = PackedVector2Array(positions)
	shader_positions.resize(64)
	return shader_positions
