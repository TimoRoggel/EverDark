class_name EatComponent extends Component

var edibles: Array = ["Apple", "VOID Grape"]

func _enter() -> void:
	controller.get_component(InputComponent).eat.connect(func() -> void:
		print("eating")
		if controller.hotbar:
			print("eat item on slot: " + str(controller.hotbar.currently_selected_slot))
			if controller.health:
				if controller.health.current_health < controller.health.max_health:
					var selected_item_name = controller.hotbar.get_selected_item_name()
					if selected_item_name:
						if selected_item_name in edibles:
							controller.hotbar.substract_item()
							controller.health.heal()
						else:
							print("item not edible!")
					else:
						print("selected slot is empty!")
				else:
					print("cant eat, health is full!")
	)
	
func _update(_delta: float) -> void:
	pass
	
func _exit() -> void:
	pass
