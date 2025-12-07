extends Node

const LUMIN_START_SIZE: float = 160.0
const LUMIN_SIZE: float = 40.0
const LUMIN_TORCH_SIZE: float = 70.0
const LUMIN_LANTERN_SIZE: float = 120.0
const OFFSET: Vector2 = Vector2(160.0, 160.0)

var lumin_positions: PackedVector2Array = [Vector2(8,8)]
var lumin_sizes: PackedFloat32Array = [LUMIN_START_SIZE]
var game_seed: int = randi()

func get_lumin_transforms() -> Array:
	var transforms: Array = []
	var positions: Array = []
	var camera: Camera2D = get_viewport().get_camera_2d()
	positions.append_array(Generator.lumin_positions)
	
	for i: int in positions.size():
		var pos: Vector2 = positions[i]
		var size: float = lumin_sizes[i]
		transforms.append([pos, size])
	
	transforms.sort_custom(func(a: Array, b: Array) -> bool:
		return a[0].distance_squared_to(camera.global_position) < b[0].distance_squared_to(camera.global_position)
	)
	transforms = transforms.map(func(a: Array) -> Array: return [Debug.to_screen(a[0]) + OFFSET, a[1]])

	while transforms.size() < 256:
		transforms.append([Vector2.ZERO, 0.0])
	transforms.resize(256)
	
	return transforms

func is_in_everdark(position: Vector2) -> bool:
	var closest_edge: float = INF
	
	for i: int in Generator.lumin_positions.size():
		var center: Vector2 = Generator.lumin_positions[i]
		var size: float = Generator.lumin_sizes[i] + 40.0
		if size <= 0.0:
			continue
		
		var center_dist: float = position.distance_to(center)
		var edge_dist: float = center_dist - size
		
		if edge_dist < closest_edge:
			closest_edge = edge_dist
	return closest_edge > 0.0

func set_lumin_size(size: float, index: int) -> void:
	lumin_sizes[index] = size

func get_lumin_positions() -> PackedVector2Array:
	return lumin_positions

func set_lumin_positions(new_lumin_positions: PackedVector2Array) -> void:
	lumin_positions = new_lumin_positions

func get_lumin_sizes() -> PackedFloat32Array:
	return lumin_sizes

func set_lumin_sizes(new_lumin_sizes: PackedFloat32Array) -> void:
	lumin_sizes = new_lumin_sizes

func get_seed() -> int:
	return game_seed

func set_seed(new_seed) -> void:
	game_seed = new_seed
