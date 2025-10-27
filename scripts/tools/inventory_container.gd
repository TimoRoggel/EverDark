@tool
class_name InventoryContainer extends GridContainer

@export var slots: int = 30:
	set(value):
		slots = value
		_redraw()
@export var rows: int = 3:
	set(value):
		rows = value
		_redraw()
@export var input_only: bool = false
@export var output_only: bool = false

signal updated

func _ready() -> void:
	_redraw()

func _clear() -> void:
	for c: Node in get_children():
		c.queue_free()

func _redraw() -> void:
	_clear()
	columns = ceili(slots / float(rows))
	for i: int in slots:
		var slot: InventorySlot = InventorySlot.new()
		slot.index = i
		slot.input_only = input_only
		slot.output_only = output_only
		slot.item_changed.connect(updated.emit)
		add_child(slot)

func add(item_id: int, quantity: int = 1) -> int:
	var inventory: Array[InventorySlot] = get_slots()
	for i: int in slots:
		if inventory[i].inventory_item == null:
			continue
		if inventory[i].inventory_item.item.id != item_id:
			continue
		if inventory[i].inventory_item.is_full():
			continue
		var remainder: int = inventory[i].inventory_item.add(quantity)
		quantity = remainder
		if quantity <= 0:
			inventory[i]._setup_item()
			return 0
	if quantity <= 0:
		return 0
	for i: int in slots:
		if inventory[i].inventory_item == null:
			inventory[i].inventory_item = InventoryItem.new(DataManager.get_resource_by_id("items", item_id), quantity)
			inventory[i]._setup_item()
			return 0
	return quantity

func remove(item_id: int, quantity: int = 1) -> int:
	var inventory: Array[InventorySlot] = get_slots()
	for i: int in slots:
		if inventory[i].inventory_item == null:
			continue
		if inventory[i].inventory_item.item.id != item_id:
			continue
		if inventory[i].inventory_item.quantity > quantity:
			inventory[i].inventory_item.quantity -= quantity
			return 0
		else:
			quantity -= inventory[i].inventory_item.quantity
			inventory[i].inventory_item = null
	return quantity
	
func clear_all():
	for slot in self.get_slots():
		if slot.inventory_item:
			slot.remove_amount(slot.inventory_item.quantity)

func has(item_id: int, quantity: int = 1) -> bool:
	return count(item_id) >= quantity

func count(item_id: int) -> int:
	var item_count: int = 0
	var inventory: Array[InventorySlot] = get_slots()
	for i: int in slots:
		if inventory[i].inventory_item == null:
			continue
		if inventory[i].inventory_item.item.id != item_id:
			continue
		item_count += inventory[i].inventory_item.quantity
	return item_count

func is_full() -> bool:
	var inventory: Array[InventorySlot] = get_slots()
	for i: int in slots:
		if !inventory[i].is_full():
			return false
	return true

func can_add(item_id: int, quantity: int = 1) -> bool:
	var inventory: Array[InventorySlot] = get_slots()
	for i: int in slots:
		if inventory[i].inventory_item == null:
			continue
		if inventory[i].inventory_item.item.id != item_id:
			continue
		if inventory[i].inventory_item.is_full():
			continue
		quantity -= inventory[i].inventory_item.item.stack_size - inventory[i].inventory_item.quantity
		if quantity <= 0:
			return true
	if quantity <= 0:
		return true
	for i: int in slots:
		if inventory[i].inventory_item == null:
			return true
	return false

func available_space(item_id: int) -> int:
	var item: Item = DataManager.get_resource_by_id("items", item_id)
	var space: int = 0
	var inventory: Array[InventorySlot] = get_slots()
	for i: int in slots:
		if inventory[i].inventory_item == null:
			space += item.stack_size
		elif inventory[i].inventory_item.item.id == item_id:
			var slot_space: int = inventory[i].inventory_item.available_space()
			if slot_space == -1:
				slot_space = item.stack_size
			space += slot_space
	return space

func sort() -> void:
	var items: Array[InventoryItem] = get_items()
	items.sort_custom(func(a: InventoryItem, b: InventoryItem) -> bool: return a.item.display_name < b.item.display_name)
	for slot: InventorySlot in get_slots():
		slot.inventory_item = null
	var current: int = 0
	var s: Array[InventorySlot] = get_slots()
	for i: int in items.size():
		var item: InventoryItem = items[i]
		var quantity: int = item.quantity
		var result: Dictionary[String, int] = { "status": OK, "remainder": quantity }
		while quantity > 0:
			if current >= slots:
				break
			result = s[current].merge(item, quantity)
			if result["status"] == OK:
				quantity = result["remainder"]
			if quantity > 0:
				current += 1
	for slot: InventorySlot in get_slots():
		slot._setup_item()

func get_items() -> Array[InventoryItem]:
	var items: Array[InventoryItem] = []
	for slot: InventorySlot in get_slots():
		if slot.inventory_item == null:
			continue
		var has_: bool = false
		for item: InventoryItem in items:
			if item.item == slot.inventory_item.item:
				item.quantity += slot.inventory_item.quantity
				has_ = true
				break
		if !has_:
			items.append(slot.inventory_item.duplicate())
	return items

func send_to_other(other: InventoryContainer, only_existing: bool = false, depth: int = 0) -> void:
	var remainder_slots: Array[InventorySlot] = []
	
	for slot: InventorySlot in get_slots():
		if slot.inventory_item == null:
			continue
		for o_slot: InventorySlot in other.get_slots():
			if o_slot.inventory_item == null:
				continue
			var result: Dictionary[String, int] = o_slot.merge(slot.inventory_item)
			if result["status"] == FAILED:
				continue
			o_slot._setup_item()
			if result["remainder"] > 0:
				slot.inventory_item.quantity = result["remainder"]
				slot._setup_item()
				remainder_slots.append(slot)
			else:
				slot.inventory_item = null
				slot._setup_item()
				remainder_slots.erase(slot)
				break
	
	if only_existing:
		send_items(other, remainder_slots)
	else:
		send_items(other, get_slots())
	
	if depth < 3:
		send_to_other(other, only_existing, depth + 1)

func send_items(other: InventoryContainer, item_slots: Array[InventorySlot]) -> void:
	for slot: InventorySlot in item_slots:
		if slot.inventory_item == null:
			continue
		if other.filter_flags & slot.inventory_item.item.flags != other.filter_flags:
			continue
		for o_slot: InventorySlot in other.get_slots():
			if o_slot.inventory_item == null:
				o_slot.inventory_item = slot.inventory_item
				slot.inventory_item = null
				o_slot._setup_item()
				slot._setup_item()
				break

func set_slots(inventory: Array[InventoryItem]) -> void:
	var children: Array[Node] = get_children()
	for i: int in get_child_count():
		var c: Node = children[i]
		if is_instance_of(c, InventorySlot):
			c.inventory_item = inventory[i]
			c._setup_item()

func get_slots() -> Array[InventorySlot]:
	var sl: Array[InventorySlot] = []
	
	for c: Node in get_children():
		if is_instance_of(c, InventorySlot):
			sl.append(c)
	
	return sl
