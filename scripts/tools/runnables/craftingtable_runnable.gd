class_name CraftingTable_runnable
extends Runnable

func run(param: Dictionary) -> void:
	var interactable = param["self"] 
	var table = interactable.get_parent() 
	var controller = param["controller"]
	
	if not table.player_ref:
		table.player_ref = controller

	if !table.crafting_ui.visible:
		table.open()
	else:
		table.close()
	
	interactable.set_active(0.1)

func can_run(param: Dictionary) -> bool:
	return param["self"].get_parent().is_interactable

func pickup(param: Dictionary) -> void:
	var interactable = param["self"]
	var table = interactable.get_parent()
	
	if table.crafting_ui.visible:
		table.close()
		
	var remainder: int = param["controller"].inventory.add(3, param.get("quantity", 1))
	if remainder == 0:
		table.queue_free()
	else:
		pass
