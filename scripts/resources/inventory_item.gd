class_name InventoryItem extends Resource

@export var item: Item = null
@export var quantity: int = 1

func _init(_item: Item = null, _quantity: int = 1) -> void:
	if _item:
		item = _item
	quantity = _quantity

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

func _to_string() -> String:
	if !item:
		return "InventoryItem<>"
	return str("InventoryItem<", item.display_name, ", ", quantity, ">")
