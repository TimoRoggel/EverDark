class_name InventoryItem extends Resource

@export var item: Item = null:
	set(value):
		item = value
		changed.emit()
@export var quantity: int = 1:
	set(value):
		quantity = value
		changed.emit()
@export var locked: bool = false:
	set(value):
		locked = value
		changed.emit()

func _init(_item: Item = null, _quantity: int = 1, _locked: bool = false) -> void:
	if _item:
		item = _item
	quantity = _quantity
	locked = _locked

func add(amount: int) -> int:
	if is_full():
		return amount
	var remainder: int = quantity + amount - item.stack_size
	if remainder < 0:
		quantity += amount
		return 0
	quantity = item.stack_size
	return remainder

func is_full() -> bool:
	return quantity >= item.stack_size

func available_space() -> int:
	if !item:
		return -1
	return item.stack_size - quantity

func _to_string() -> String:
	if !item:
		return "InventoryItem<>"
	return str("InventoryItem<", item.display_name, ", ", quantity, ">")
