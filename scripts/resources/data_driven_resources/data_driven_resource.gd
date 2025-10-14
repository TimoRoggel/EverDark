@abstract
class_name DataDrivenResource extends Resource

@export var id: int = -1

static func get_loaded(data: Dictionary, key: String, default: Variant = null) -> Variant:
	if data.has(key) && !data[key].is_empty():
		return load(data[key])
	return default
