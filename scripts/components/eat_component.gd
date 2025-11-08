class_name EatComponent extends Component

var edibles: Array = ["VOID Core"]

func _enter() -> void:
	controller.get_component(InputComponent).eat.connect(func() -> void:
		if controller.hotbar:
			if controller.health:
				if controller.health.current_health < controller.health.max_health:
					var selected_item_name = controller.hotbar.get_selected_item_name()
					if selected_item_name:
						if selected_item_name in edibles:
							controller.hotbar.substract_item()
							controller.health.heal()
						else:
							#item not edible!
							pass
					else:
						#selected slot is empty!
						pass
				else:
					#cant eat, health is full!
					pass
	)
	
func _update(_delta: float) -> void:
	pass
	
func _exit() -> void:
	pass
