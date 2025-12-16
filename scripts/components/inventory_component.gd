class_name InventoryComponent extends Component

@export var slots: int = 15
@export var container: InventoryContainer = null
var held_item: int = 0

signal updated

func _enter() -> void:
	for slot: InventorySlot in container.get_slots():
		slot.item_dropped.connect(_on_item_dropped)
	controller.get_component(InputComponent).inventory_toggled.connect(toggle_inventory)
	container.updated.connect(updated.emit)
	SaveSystem.track("inventory", get_inventory, set_inventory.call_deferred, [[7, 1], [1, 1]])
	#await get_tree().create_timer(0.25).timeout
	#set_inventory([[0, 99], [24, 99]])

func toggle_inventory() -> void:
	if container.visible:
		close()
	else:
		open()

func open() -> void:
	container.visible = true
	if controller.hotbar:
		controller.hotbar.visible = false
	
	GameManager.set_active_ui(self)

func close() -> void:
	container.visible = false
	if controller.hotbar:
		controller.hotbar.visible = true
		
	GameManager.clear_active_ui()

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_item_dropped(item: InventoryItem) -> void:
	DroppedItem2D.drop(item.item.id, item.quantity, global_position)
	if !controller.animation.forced_animation_playing:
		controller.animation.play("pickdrop")
	
func drop_all():
	if not is_empty():
		for slot in container.get_slots():
			var random_vector = random_spread_pos(controller.global_position, 20)
			if slot.inventory_item:
				DroppedItem2D.drop(slot.inventory_item.item.id, slot.inventory_item.quantity, random_vector)
	container.clear_all()
	
func drop_items(percent: float):
	var filled_slots: Array = []
	if not is_empty():
		for slot in container.get_slots():
			if slot.inventory_item:
				filled_slots.append(slot)
				
	var drop_count := int(round(filled_slots.size() * (percent / 100.0)))
	filled_slots.shuffle()
	var chosen_slots := filled_slots.slice(0, drop_count)
	for slot in chosen_slots:
		var random_vector = random_spread_pos(controller.global_position, 20)
		DroppedItem2D.drop(slot.inventory_item.item.id, slot.inventory_item.quantity, random_vector)
	container.clear_all()

func add(item_id: int, quantity: int = 1) -> int:
	if (item_id == 6 && has(18)) || (item_id == 18 && has(6)):
		GameManager.finish_objective(2)
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
	return item_id in [3, 4, 26]

func random_spread_pos(entity_location, item_spread_radius) -> Vector2:
	var rand_x = randf_range(entity_location.x - item_spread_radius, entity_location.x + item_spread_radius) 
	var rand_y = randf_range(entity_location.y + item_spread_radius, entity_location.y - item_spread_radius)
	var random_vector = Vector2(rand_x, rand_y)
	return random_vector

func get_inventory() -> Array:
	var items: Array = []
	for slot: InventorySlot in container.get_slots():
		if slot.is_empty():
			items.append([])
			continue
		var item: InventoryItem = slot.inventory_item
		items.append([item.item.id, item.quantity])
	return items

func set_inventory(new_inventory: Array) -> void:
	var s: Array[InventoryItem] = []
	s.resize(slots)
	new_inventory.resize(slots)
	for i: int in slots:
		if new_inventory[i] == null || new_inventory[i].is_empty():
			s[i] = null
		else:
			var item: Array = new_inventory[i]
			s[i] = InventoryItem.new(DataManager.get_resource_by_id("items", item[0]), item[1])
	container.set_slots(s)
