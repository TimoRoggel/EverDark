class_name CampfireRunnable extends Runnable

func run(param: Dictionary) -> void:
	var interactable: Interactable2D = param["self"]
	var controller: PlayerController = param["controller"]
	var hud: CanvasLayer = interactable.get_child(1)
	var ui_control = hud.get_child(0)
	
	if !hud.visible:
		ui_control.open()
	else:
		ui_control.close()
	hud.get_child(0).check_recipe_availability()
	hud.get_tree().paused = true
	controller.hotbar.visible = false
	controller.inventory.container.visible = true

func can_run(param: Dictionary) -> bool:
	var controller: PlayerController = param["controller"]
	if !controller || !controller.inventory:
		return false
	return true
