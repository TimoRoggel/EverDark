class_name GeneratedTileMapLayer extends FlippableTileMapLayer

const GENERATED_PER_FRAME: int = 2

@export var toppings_layer: FlippableTileMapLayer = null

var generated_chunks: Array[Vector2] = []
var terrain_queue: Dictionary[Vector3i, Array] = {}
var processed_terrains: Array[Vector2i] = []
var everdark_queue: Array[Vector2] = []
var queueing: bool = false

signal chunk_generated(chunk: Vector2i)
signal everdark_queue_done

func process_terrain_queue(chunk: Vector2i) -> void:
	if processed_terrains.has(chunk):
		return
	var processing_dimension: int = Generator.dimension
	processed_terrains.append(chunk)
	if !terrain_queue.has(Vector3i(chunk.x, chunk.y, processing_dimension)):
		return
	var terrains: Dictionary[Vector3i, Array] = {}
	for addition: Array in terrain_queue[Vector3i(chunk.x, chunk.y, processing_dimension)]:
		var key: Vector3i = Vector3i(1 if addition[0] == true else 0, addition[1], addition[2])
		if !terrains.has(key):
			terrains[key] = []
		terrains[key].append(addition[3])
		await get_tree().process_frame
	for key: Vector3i in terrains.keys():
		if processing_dimension != Generator.dimension:
			break
		place_terrain(key, terrains)
		await get_tree().process_frame
	chunk_generated.emit(chunk)

func place_terrain(key: Vector3i, terrains: Dictionary[Vector3i, Array]) -> void:
	var layer: FlippableTileMapLayer = toppings_layer if key.x == 1 else self
	layer.set_cells_terrain_connect(terrains[key], key.y, key.z)

func queue_everdark() -> void:
	queueing = true
	var i: int = 0
	for coords: Vector2 in everdark_queue:
		place_everdark(coords)
		if i % 3 == 0:
			await get_tree().process_frame
		i += 1
	everdark_queue.clear()
	queueing = false
	everdark_queue_done.emit()

func clear_tiles() -> void:
	generated_chunks.clear()
	processed_terrains.clear()
	clear()
	toppings_layer.clear()

func generate_around(where: Vector2, amount: int = 1) -> void:
	var max_radius: int = Generator.SIZE * amount
	for r: int in max_radius + 1:
		var steps: int = 80
		for t: int in steps:
			var p: float = t * TAU / steps
			var x: int = roundi(sin(p) * r)
			var y: int = roundi(cos(p) * r)
			var pos: Vector2 = where + Vector2(x, y)
			if pos.distance_squared_to(where) >= pow(max_radius + 1, 2.0):
				continue
			var e_x: int = roundi(sin(p) * (r + 1))
			var e_y: int = roundi(cos(p) * (r + 1))
			if r >= max_radius:
				if queueing:
					await everdark_queue_done
				everdark_queue.append(where + Vector2(e_x, e_y))
			if r <= max_radius:
				generate(pos)
		await get_tree().physics_frame
	queue_everdark()

func generate(where: Vector2) -> void:
	if generated_chunks.has(where):
		return
	generated_chunks.append(where)
	#find_and_place_tile(where)
	process_terrain_queue(where)


func place_tile(at: Vector2, tile: BiomeTile, topping: bool = false) -> void:
	if !tile:
		return
	var layer: TileMapLayer = toppings_layer if topping else self
	if tile.flippable_h || tile.flippable_v:
		var flip_h: bool = tile.flippable_h && Generator.get_noise(Generator.toppings_map, at.x, at.y + 1) > 0.5
		var flip_v: bool = tile.flippable_v && Generator.get_noise(Generator.toppings_map, at.x + 1, at.y) > 0.5
		var transpose: bool = tile.flippable_v && tile.flippable_h && Generator.get_noise(Generator.toppings_map, at.x + 1, at.y + 1) > 0.5
		layer.set_tile_flip(at, flip_h, flip_v, transpose)
	layer.set_cell(at, tile.source, tile.coordinates)
	layer.notify_runtime_tile_data_update()
	#if tile.terrain < 0:
		#layer.set_cell(at, tile.source, tile.coordinates)
	#else:
		#var chunk: Vector2i = Generator.get_chunk(at, true)
		#var dchunk: Vector3i = Vector3i(chunk.x, chunk.y, Generator.dimension)
		#if !terrain_queue.has(dchunk):
			#terrain_queue[dchunk] = []
		#terrain_queue[dchunk].append([topping, tile.source, tile.terrain, at, true])

func place_everdark(at: Vector2) -> void:
	if generated_chunks.has(at):
		return
	set_cell(at, 4, Vector2i.ZERO, 1)
