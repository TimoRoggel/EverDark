class_name ItemPickupRunnable extends Runnable

func run(param: Dictionary) -> void:
	if !param.has("item"):
		return
	param["controller"].inventory.add(param["item"], param.get("quantity", 1))
	param["self"].queue_free()

func can_run(param: Dictionary) -> bool:
	if !param.has("item"):
		return false
	return param["controller"].inventory.can_add(param["item"], param.get("quantity", 1))
