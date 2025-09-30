class_name ItemPickupRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("item"):
		return
	var remainder: int = param["controller"].inventory.add(param["item"], param.get("quantity", 1))
	if remainder > 0:
		param["self"].amount = remainder
		param["self"].global_position = param["controller"].global_position
	else:
		param["self"].queue_free()

func can_run(param: Dictionary) -> bool:
	if !param.has("item"):
		return false
	return param["controller"].inventory.available_space(param["item"]) > 0
