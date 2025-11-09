@tool
class_name Biome extends Resource

const CAVE_ODDS: float = 0.1

@export var id: String = ""
@export var source: int = 0
@export_group("Vector")
@export var dimension: int = 0
@export var vectors: Array[BiomeVector] = []:
	set(value):
		vectors = validate_vectors(value)
@export_group("Ground")
@export var ground_tiles: Array[BiomeTile] = []:
	set(value):
		ground_tiles = validate_tiles(value)
@export var topping_tiles: Array[BiomeTile] = []:
	set(value):
		topping_tiles = validate_tiles(value)
@export_group("Water")
@export_subgroup("River", "river_")
@export var river_enabled: bool = true
@export var river_tile: BiomeTile = BiomeTile.new(1, Vector2i.ZERO, 0)
@export var river_bank_tile: BiomeTile = BiomeTile.new(2, Vector2i.ZERO, 0)
@export_range(0.0, 1.0, 0.0001) var river_bank_size: float = 0.05
@export_subgroup("Lakes", "lake_")
@export var lake_enabled: bool = true
@export var lake_tile: BiomeTile = BiomeTile.new(1, Vector2i.ZERO, 0)
@export_range(0.0, 1.0, 0.0001) var lake_size: float = 0.25
@export var lake_bank_tile: BiomeTile = BiomeTile.new(2, Vector2i.ZERO, 0)
@export_range(0.0, 1.0, 0.0001) var lake_bank_size: float = 0.05
@export_group("Caves")
@export var cave_entrance: BiomeTile = BiomeTile.new(0, Vector2i(4, 5))
@export var has_cave_walls: bool = false
@export var wall_tiles: Array[BiomeTile] = []:
	set(value):
		wall_tiles = validate_tiles(value)
@export_group("Misc")
@export var tone: Color = Color.WHITE

static func from_data(data: Dictionary) -> Biome:
	var biome: Biome = Biome.new()
	biome.id = data["id"]
	biome.source = data["source"]
	biome.dimension = data["dimension"]
	biome.vectors = []
	for v: Array in data["vectors"]:
		biome.vectors.append(BiomeVector.new(v[0], v[1], v[2], v[3], v[4]))
	biome.ground_tiles = []
	for gt: String in data["ground_tiles"]:
		biome.ground_tiles.append(load(gt))
	biome.topping_tiles = []
	for tt: String in data["topping_tiles"]:
		biome.topping_tiles.append(load(tt))
	biome.river_enabled = data["river_enabled"]
	return biome

func distance_to(vector: BiomeVector) -> float:
	var lowest_distance: float = 99999.9
	for v: BiomeVector in vectors:
		var distance: float = v.distance_to(vector)
		if distance < lowest_distance:
			lowest_distance = distance
	return lowest_distance

func validate_tiles(property: Array[BiomeTile]) -> Array[BiomeTile]:
	if Engine.is_editor_hint():
		var new_prop: Array[BiomeTile] = []
		for tile: BiomeTile in property:
			if !tile:
				tile = BiomeTile.new(source, Vector2i.ZERO)
			new_prop.append(tile)
		property = new_prop
	return property

func validate_vectors(property: Array[BiomeVector]) -> Array[BiomeVector]:
	if Engine.is_editor_hint():
		var new_prop: Array[BiomeVector] = []
		for vector: BiomeVector in property:
			if !vector:
				vector = BiomeVector.new()
			new_prop.append(vector)
		property = new_prop
	return property
