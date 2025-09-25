class_name InventorySlotCrafting
extends Panel

@onready var texture_rect : TextureRect = %TextureRect

var item_data : ItemData = null

func set_item_data(new_item : ItemData) -> void:
	item_data = new_item
	texture_rect.texture = item_data.item_texture
