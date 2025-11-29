extends Node

const LUMIN_SIZE: float = 132.0

var lumin_positions: PackedVector2Array = [Vector2(8,8)]
var game_seed: int = randi()

func _ready() -> void:
	SaveSystem.track("lumin_positions", get_lumin_positions, set_lumin_positions, [Vector2(8,8)])
	SaveSystem.track("seed", get_seed, set_seed, randi())

func get_lumin_positions() -> PackedVector2Array:
	return lumin_positions

func set_lumin_positions(new_lumin_positions: PackedVector2Array) -> void:
	lumin_positions = new_lumin_positions

func get_seed() -> int:
	return game_seed

func set_seed(new_seed) -> void:
	game_seed = new_seed
