class_name BiomeTile extends Resource

@export var source: int = -1
@export var coordinates: Vector2i = Vector2i.ZERO
@export var terrain: int = -1
@export_range(0.0, 1.0, 0.0001) var chance: float = 1.0
@export var flippable_h: bool = false
@export var flippable_v: bool = false

func _init(_source: int = -1, _coordinates: Vector2i = Vector2i.ZERO, _terrain: int = -1, _chance: float = 1.0) -> void:
	source = _source
	coordinates = _coordinates
	terrain = _terrain
	chance = _chance

static func get_tile(collection: Array[BiomeTile], value: float, nullable: bool = false) -> BiomeTile:
	if collection.size() < 1:
		return null
	collection.sort_custom(func(a: BiomeTile, b: BiomeTile) -> bool: return a.chance < b.chance)
	for tile: BiomeTile in collection:
		if value < tile.chance:
			return tile
	if nullable:
		return null
	return collection[collection.size() - 1]

func _to_string() -> String:
	return "<BiomeTile=(source:" + str(source) + ",coords:" + str(coordinates) + ",terrain:" + str(terrain) + ",chance:" + str(chance) + ")>"
