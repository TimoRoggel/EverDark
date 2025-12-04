class_name ArrayHelper extends Node

static func make_unique(arr: Array) -> Array:
	var new_array: Array = []
	for element: Variant in arr:
		if new_array.has(element):
			continue
		new_array.append(element)
	return new_array
