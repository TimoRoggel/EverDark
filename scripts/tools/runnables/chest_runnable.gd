class_name Chest_runnable
extends Runnable

@export var chest_item_id: int = 4

func run(param: Dictionary) -> void:
	var controller = param["controller"]
	var interactable = param["self"]         
	var chest = interactable.get_parent()    
	var input = controller.get_component(InputComponent)

	if input and input.is_pickup_pressed():
		_pickup(controller, chest)
	else:
		_toggle_ui(controller, chest)

func can_run(param: Dictionary) -> bool:
	var controller = param["controller"]
	if !controller or !controller.inventory:
		return false
	var input = controller.get_component(InputComponent)
	if input and input.is_pickup_pressed():
		return controller.inventory.available_space(chest_item_id) > 0
	return true

func _toggle_ui(controller, chest) -> void:
	var new_visible = !chest.chest_inventory.visible
	chest.chest_inventory.visible = new_visible
	controller.inventory.container.visible = new_visible

func _pickup(controller, chest) -> void:
	for item in chest.chest_inventory.get_items():
		var leftover = controller.inventory.add(item.item.id, item.quantity)
		if leftover > 0:
			var dropped_item: DroppedItem2D = DroppedItem2D.new()
			dropped_item.item = item.item
			dropped_item.quantity = leftover
			chest.get_parent().add_child(dropped_item)
			dropped_item.global_position = chest.global_position

	var remainder: int = controller.inventory.add(chest_item_id, 1)
	if remainder == 0:
		chest.queue_free()
