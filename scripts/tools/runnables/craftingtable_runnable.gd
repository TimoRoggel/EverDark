class_name CraftingTable_runnable
extends Runnable

func run(param: Dictionary) -> void:
	var table = param["self"]
	if table.has_method("toggle_ui"):
		table.toggle_ui(param["controller"])

func can_run(_param: Dictionary) -> bool:
	return true

func pickup(param: Dictionary) -> void:
	var remainder: int = param["controller"].inventory.add(3, param.get("quantity", 1))
	if remainder == 0:
		param["self"].queue_free()
	else:
		pass
