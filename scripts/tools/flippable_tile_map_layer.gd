class_name FlippableTileMapLayer extends TileMapLayer

var flipped_tiles: Dictionary[Vector2i, Array] = {}
var has_updated: bool = false

func set_tile_flip(coords: Vector2i, flip_h: bool = false, flip_v: bool = false, transpose: bool = false) -> void:
	flipped_tiles[coords] = [flip_h, flip_v, transpose]

func _process(_delta: float) -> void:
	has_updated = false

func _use_tile_data_runtime_update(coords: Vector2i) -> bool:
	return !has_updated && flipped_tiles.has(coords)
	
func _tile_data_runtime_update(coords: Vector2i, tile_data: TileData) -> void:
	tile_data.flip_v = flipped_tiles[coords][0]
	tile_data.flip_h = flipped_tiles[coords][1]
	tile_data.transpose = flipped_tiles[coords][2]
	has_updated = true
