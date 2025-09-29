class_name InventorySlotCrafting
extends Panel

@onready var texture_rect: TextureRect = %TextureRect
@onready var count_label: Label = %CountLabel 

var item_data: Item = null
var current_amount: int = 0
var required_amount: int = 0

func set_item_data(new_item: Item, current: int = 0, required: int = 0) -> void:
	item_data = new_item
	current_amount = current
	required_amount = required
	texture_rect.texture = item_data.icon
	count_label.text = str(current_amount, " / ", required_amount)

	if current_amount < required_amount:
		count_label.modulate = Color(1, 0.3, 0.3)
	else:
		count_label.modulate = Color(1, 1, 1)
