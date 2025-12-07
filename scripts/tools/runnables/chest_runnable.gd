class_name Chest_runnable
extends Runnable

const OPEN_SOUND = preload("uid://cs5o8fl5xusr1")

@export var chest_item_id: int = 4

func run(param: Dictionary) -> void:
	var controller: PlayerController = param["controller"]
	var interactable: Interactable2D = param["self"]
	var chest: Chest = interactable.get_parent()
	var input: InputComponent = controller.get_component(InputComponent)
	
	if input && input.is_pickup_pressed():
		_pickup(controller, chest)
	else:
		_toggle_ui(controller, chest)

func can_run(param: Dictionary) -> bool:
	var controller: PlayerController = param["controller"]
	if !controller || !controller.inventory:
		return false
	var input: InputComponent = controller.get_component(InputComponent)
	if input && input.is_pickup_pressed():
		return controller.inventory.available_space(chest_item_id) > 0
	return true

func _toggle_ui(_controller: PlayerController, chest: Chest) -> void:
	if !chest.chest_inventory.visible:
		chest.open_close_sound.stream = OPEN_SOUND
		chest.open_close_sound.play()
		chest.open()
	else:
		chest.close()

func _pickup(controller: PlayerController, chest: Chest) -> void:
	if chest.chest_inventory.visible:
		chest.close()

	for item: InventoryItem in chest.chest_inventory.get_items():
		var leftover: int = controller.inventory.add(item.item.id, item.quantity)
		if leftover > 0:
			DroppedItem2D.drop(item.item.id, leftover, chest.global_position)

	var remainder: int = controller.inventory.add(chest_item_id, 1)
	if remainder == 0:
		chest.queue_free()
