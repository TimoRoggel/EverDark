class_name Chest_runnable extends Runnable

func run(param: Dictionary) -> void:
	var _remainder: int = param["controller"].inventory.add(4, param.get("quantity", 1))
	param["self"].get_parent().queue_free()

func can_run(param: Dictionary) -> bool:
	if !param["controller"].inventory:
		return false
	return param["controller"].inventory.available_space(4) > 0
