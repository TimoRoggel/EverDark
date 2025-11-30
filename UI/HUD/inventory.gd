extends Control

@onready var item_description: Label = $MarginContainer/VBoxContainer/ItemDescription
@onready var inventory_container: InventoryContainer1 = $MarginContainer/VBoxContainer/HBoxContainer/InventoryContainer
@onready var selected_icon: TextureRect = $SelectedIcon

func _ready() -> void:
	inventory_container.slot_clicked.connect(_on_inventory_slot_clicked)
	clear_info()

func _on_inventory_slot_clicked(item: InventoryItem) -> void:
	if item == null:
		clear_info()
		return
	
	selected_icon.texture = item.item.icon
	var text = "[b]" + item.item.display_name + "[/b] (" + str(item.quantity) + ")\n"
	
	if "description" in item.item:
		text += str(item.item.description)
		
	item_description.text = text

func clear_info() -> void:
	selected_icon.texture = null
	item_description.text = "Select Item"
