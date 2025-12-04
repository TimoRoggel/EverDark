class_name CampfireRunnable extends Runnable

func run(param: Dictionary) -> void:
	var interactable: Interactable2D = param["self"]
	var hud: CanvasLayer = interactable.get_child(1)
	var ui_control = hud.get_child(0)
	
	if !hud.visible:
		ui_control.open()
	else:
		ui_control.close()

func can_run(param: Dictionary) -> bool:
	var controller: PlayerController = param["controller"]
	if !controller || !controller.inventory:
		return false
	return true
