class_name InventorySlotCrafting
extends Panel

@onready var texture_rect : TextureRect = %TextureRect

var item_data : Item = null

func set_item_data(new_item : Item) -> void:
	item_data = new_item
	texture_rect.texture = item_data.icon
