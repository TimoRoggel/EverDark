class_name SequenceHelper extends Node

static func spiral_t(start_position: Vector2i, max_distance: int, callable: Callable, iteration_size: int = 1) -> Vector2i:
	return await SequenceHelper.spiral(start_position, max_distance, callable, iteration_size)

static func spiral(start_position: Vector2i, max_distance: int, callable: Callable, iteration_size: int = 1) -> Vector2i:
	await callable.call(start_position, 0)
	
	var check_position: Vector2i = start_position
	var step_size: int = 1
	var dx: int = 1
	var dy: int = 0
	var distance: int = 1
	
	var iteration: int = 0
	
	while distance <= max_distance:
		for i: int in range(2):
			for j: int in range(step_size):
				check_position.x += dx * iteration_size
				check_position.y += dy * iteration_size
				distance = max(abs(check_position.x - start_position.x), abs(check_position.y - start_position.y)) / iteration_size
				
				if distance > max_distance:
					return Vector2i.ZERO
				
				iteration += 1
				
				if callable == null || callable.is_null():
					return Vector2i.ZERO
				
				if await callable.call(check_position, iteration):
					return check_position
			var tdx: int = dx
			dx = -dy
			dy = tdx
		step_size += 1
	return Vector2i.ZERO
