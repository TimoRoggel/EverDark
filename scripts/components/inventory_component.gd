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
	
func drop_all():
	print("dropping...")
	if not is_empty():
		for slot in container.get_slots():
			var random_vector = random_spread_pos(controller.global_position, 20)
			print("slot")
			if slot.inventory_item:
				print("item")
				DroppedItem2D.drop(slot.inventory_item.item.id, slot.inventory_item.quantity, random_vector)
	container.clear_all()
	
	
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

func random_spread_pos(entity_location, item_spread_radius) -> Vector2:
	var rand_x = randf_range(entity_location.x - item_spread_radius, entity_location.x + item_spread_radius) 
	var rand_y = randf_range(entity_location.y + item_spread_radius, entity_location.y - item_spread_radius)
	var random_vector = Vector2(rand_x, rand_y)
	return random_vector

