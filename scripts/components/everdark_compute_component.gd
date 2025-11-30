class_name EverdarkComputeComponent extends Component

var everdark_material: ShaderMaterial = null
var camera: Camera2D = null

func _enter() -> void:
	everdark_material = load("uid://dpfoqgjxxik6t")
	camera = controller.get_component(CameraComponent).camera
	everdark_material.set_shader_parameter("lumin_circle_start", Generator.LUMIN_SIZE)
	everdark_material.set_shader_parameter("lumin_circle_end", Generator.LUMIN_SIZE + 16.0)
	updates_in_physics = false

func _update(_delta: float) -> void:
	var lumin_transforms: Array = Generator.get_lumin_transforms()
	everdark_material.set_shader_parameter("lumin_positions", lumin_transforms.map(func(t: Array) -> Vector2: return t[0]))
	everdark_material.set_shader_parameter("lumin_sizes", lumin_transforms.map(func(t: Array) -> float: return t[1]))
	everdark_material.set_shader_parameter("lumin_count", min(256, Generator.lumin_positions.size()))
	everdark_material.set_shader_parameter("player_position", Debug.to_screen(global_position) + Generator.OFFSET)

func _exit() -> void:
	pass
