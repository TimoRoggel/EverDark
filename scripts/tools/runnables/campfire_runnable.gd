class_name CampfireRunnable extends Runnable

func run(param: Dictionary) -> void:
	var interactable: Interactable2D = param["self"]
	var hud: CanvasLayer = interactable.get_child(1)
	hud.visible = !hud.visible
	hud.get_child(0).check_recipe_availability()

func can_run(param: Dictionary) -> bool:
	var controller: PlayerController = param["controller"]
	if !controller || !controller.inventory:
		return false
	return true
