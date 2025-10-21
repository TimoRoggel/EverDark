class_name InventoryComponent extends Component

@export var slots: int = 30
@export var container: InventoryContainer = null
var held_item: int = 0

func _enter() -> void:
	for slot: InventorySlot in container.get_slots():
		slot.item_dropped.connect(_on_item_dropped)
	controller.get_component(InputComponent).inventory_toggled.connect(func() -> void:
		container.visible = !container.visible
	)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_item_dropped(item: InventoryItem) -> void:
	var pickup: DroppedItem2D = DroppedItem2D.new()
	pickup.item = item.item
	pickup.amount = item.quantity
	controller.add_sibling(pickup)
	pickup.timeout()
	pickup.global_position = global_position

func add(item_id: int, quantity: int = 1) -> int:
	return container.add(item_id, quantity)

func remove(item_id: int, quantity: int = 1) -> int:
	return container.remove(item_id, quantity)

func has(item_id: int, quantity: int = 1) -> bool:
	return container.has(item_id, quantity)

func count(item_id: int) -> int:
	return container.count(item_id)

func list() -> Array[InventoryItem]:
	return container.get_items()

func is_empty() -> bool:
	return list().is_empty()

func is_full() -> bool:
	return container.is_full()

func can_add(item_id: int, quantity: int = 1) -> bool:
	return container.can_add(item_id, quantity)

func available_space(item_id: int) -> int:
	return container.available_space(item_id)

func get_held_item_id() -> int:
	return held_item
	
func set_held_item_id(item_id: int) -> void:
	held_item = item_id

func is_placeable(item_id: int) -> bool:
	return item_id in [3, 4]
