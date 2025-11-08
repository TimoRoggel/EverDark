@abstract
class_name DataDrivenResource extends Resource

@export var id: int = -1

static func get_loaded(data: Dictionary, key: String, default: Variant = null) -> Variant:
	if data.has(key):
		var obj: Variant = data[key]
		match typeof(obj):
			TYPE_STRING:
				if !obj.is_empty():
					if ResourceUID.has_id(ResourceUID.text_to_id(obj)):
						return load(obj)
	return default
