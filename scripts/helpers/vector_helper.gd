class_name VectorHelper extends Node

static func avg(arr: PackedVector2Array) -> Vector2:
	return VectorHelper.add(arr) / arr.size()

static func add(arr: PackedVector2Array) -> Vector2:
	var total: Vector2 = Vector2.ZERO
	for v: Vector2 in arr:
		total += v
	return total
