extends Node

const BASE_FREQUENCY: float = 0.05
const SIZE: int = 7
const HSIZE: int = int(round(SIZE / 2.0))
const BIOME_SIZE: float = 1.0
const RIVER_SIZE: float = 0.15
const DIMENSIONS: int = 1

# Noise Maps
var temperature_map: FastNoiseLite = null
var humidity_map: FastNoiseLite = null
var height_map: FastNoiseLite = null
var fertility_map: FastNoiseLite = null
var weirdness_map: FastNoiseLite = null
var cave_map: FastNoiseLite = null
var toppings_map: FastNoiseLite = null
var odds_map: FastNoiseLite = null
var lake_map: FastNoiseLite = null
var river_map: FastNoiseLite = null

var layer: GeneratedTileMapLayer = null:
	set(value):
		layer = value
		layer_assigned.emit()
var dimension: int = 0
var lumin_positions: PackedVector2Array = [Vector2(8,8)]

signal layer_assigned

func _ready() -> void:
	initialize_maps()

func _physics_process(_delta: float) -> void:
	if GameManager.main_camera_component == null:
		return
	if layer == null:
		return
	var player_pos: Vector2i = layer.local_to_map(GameManager.main_camera_component.global_position)
	var thhf: Vector4 = Vector4.ZERO
	thhf.x = get_noise(temperature_map, player_pos.x, player_pos.y)
	thhf.y = get_noise(humidity_map, player_pos.x, player_pos.y)
	thhf.z = get_noise(height_map, player_pos.x, player_pos.y)
	thhf.w = get_noise(fertility_map, player_pos.x, player_pos.y)
	#Debug.add_value("Noise (Temp, Humid, Height, Fert)", thhf)
	var wcto: Vector4 = Vector4.ZERO
	wcto.x = get_noise(weirdness_map, player_pos.x, player_pos.y)
	wcto.y = get_noise(cave_map, player_pos.x, player_pos.y)
	wcto.z = get_noise(toppings_map, player_pos.x, player_pos.y)
	wcto.w = get_noise(odds_map, player_pos.x, player_pos.y)
	#Debug.add_value("Noise (Weird, Cave, Top, Odds)", wcto)
	var lrxx: Vector4 = Vector4.ZERO
	lrxx.x = get_noise(lake_map, player_pos.x, player_pos.y)
	lrxx.y = get_noise(river_map, player_pos.x, player_pos.y)
	#Debug.add_value("Noise (Lake, River, X, X)", lrxx)
	#Debug.add_value("Biome", get_biome(player_pos.x, player_pos.y).id)

func generate(at: Vector2, amount: int = 1) -> void:
	await layer.generate_around(layer.local_to_map(at) / SIZE, amount)

func get_tile(x: float, y: float) -> BiomeTile:
	var biome: Biome = get_biome(x, y)
	if biome == null:
		return null
	if biome.river_enabled || biome.lake_enabled:
		var river_noise = get_noise(river_map, x, y)
		var lake_noise = get_noise(lake_map, x, y)
		if biome.river_enabled && river_noise > 1.0 - RIVER_SIZE:
			return biome.river_tile
		if biome.lake_enabled && lake_noise > 1.0 - biome.lake_size:
			return biome.lake_tile
		if biome.river_enabled && river_noise + biome.river_bank_size > 1.0 - RIVER_SIZE:
			return biome.river_bank_tile
		if biome.lake_enabled && lake_noise + biome.lake_bank_size > 1.0 - biome.lake_size:
			return biome.lake_bank_tile
	var is_cave_path: bool = get_noise(cave_map, x, y) > 0.25
	var cave_entrance_placed: bool = false
	if biome.cave_entrance != null:
		if is_cave_path && get_noise(toppings_map, x, y) <= Biome.CAVE_ODDS:
			layer.place_tile(Vector2(x, y), biome.cave_entrance, true)
			cave_entrance_placed = true
	if !cave_entrance_placed:
		var topping: BiomeTile = BiomeTile.get_tile(biome.topping_tiles, get_noise(toppings_map, x, y), true)
		if topping:
			layer.place_tile(Vector2(x, y), topping, true)
	if biome.has_cave_walls:
		if !is_cave_path:
			return BiomeTile.get_tile(biome.wall_tiles, get_noise(odds_map, x, y))
	return BiomeTile.get_tile(biome.ground_tiles, get_noise(odds_map, x, y))

func get_biome(x: float, y: float) -> Biome:
	x *= BIOME_SIZE
	y *= BIOME_SIZE
	var biome_vector: BiomeVector = BiomeVector.new(get_noise(temperature_map, x, y), get_noise(humidity_map, x, y), get_noise(height_map, x, y), get_noise(fertility_map, x, y), get_noise(weirdness_map, x, y))
	var biomes: Array = DataManager.resources["biomes"].duplicate()
	biomes = biomes.filter(func(biome: Biome) -> bool: return biome.dimension == dimension)
	biomes.sort_custom(func (a: Biome, b: Biome) -> bool: return a.distance_to(biome_vector) < b.distance_to(biome_vector))
	return biomes[0]

func get_noise(map: FastNoiseLite, x: float, y: float) -> float:
	return (map.get_noise_2d(x, y) + 1.0) / 2.0

func swap_dimension(new_dimension: int = 0) -> void:
	dimension = new_dimension
	layer.clear_tiles()
	GameManager.player.last_generate_position = Vector2.INF

func get_chunk(pos: Vector2, is_mapped: bool = false) -> Vector2i:
	if !is_mapped:
		pos /= SIZE
	pos /= SIZE
	return Vector2i(round(pos))

func initialize_maps() -> void:
	# Temperature
	temperature_map = initialize_map(BASE_FREQUENCY * 0.04, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH)
	# Humidity
	humidity_map = initialize_map(BASE_FREQUENCY * 0.02, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH)
	# Height
	height_map = initialize_map(BASE_FREQUENCY * 0.01, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH)
	# Fertility
	fertility_map = initialize_map(BASE_FREQUENCY * 0.7, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH)
	# Weirdness
	weirdness_map = initialize_map(BASE_FREQUENCY * 0.2, FastNoiseLite.NoiseType.TYPE_PERLIN)
	# Cave
	cave_map = initialize_map(0.06, FastNoiseLite.NoiseType.TYPE_CELLULAR)
	cave_map.fractal_octaves = 6
	cave_map.fractal_lacunarity = 3.5
	cave_map.fractal_gain = 0.1
	# Toppings
	toppings_map = initialize_map(1.0, FastNoiseLite.NoiseType.TYPE_VALUE)
	# Odds
	odds_map = initialize_map(0.05, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH)
	odds_map.fractal_gain = 0.05
	odds_map.fractal_weighted_strength = 1.0
	# Lake
	lake_map = initialize_map(BASE_FREQUENCY * 0.5, FastNoiseLite.NoiseType.TYPE_SIMPLEX_SMOOTH)
	lake_map.fractal_gain = 0.05
	lake_map.fractal_weighted_strength = 1.0
	# River
	river_map = initialize_map(0.0075, FastNoiseLite.NoiseType.TYPE_CELLULAR)
	river_map.fractal_type = FastNoiseLite.FRACTAL_RIDGED
	river_map.fractal_gain = 1.125
	river_map.fractal_octaves = 1
	river_map.fractal_weighted_strength = 1.0
	river_map.cellular_distance_function = FastNoiseLite.DISTANCE_EUCLIDEAN_SQUARED
	river_map.cellular_return_type = FastNoiseLite.RETURN_DISTANCE2_DIV
	river_map.domain_warp_enabled = true
	river_map.domain_warp_type = FastNoiseLite.DOMAIN_WARP_SIMPLEX_REDUCED
	river_map.domain_warp_amplitude = 16.5
	river_map.domain_warp_frequency = 0.03
	river_map.domain_warp_fractal_type = FastNoiseLite.DOMAIN_WARP_FRACTAL_NONE
	river_map.domain_warp_fractal_octaves = 6
	river_map.domain_warp_fractal_gain = 0.0

func initialize_map(frequency: float, noise_type: FastNoiseLite.NoiseType) -> FastNoiseLite:
	var map: FastNoiseLite = FastNoiseLite.new()
	map.frequency = frequency
	map.noise_type = noise_type
	map.seed = randi()
	return map
