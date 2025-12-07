class_name InventorySlotCrafting
extends Panel

@onready var texture_rect: TextureRect = $TextureRect
@onready var count_label: Label = $CountLabel 

var item_data: Item = null
var current_amount: int = 0
var required_amount: int = 0

func set_item_data(new_item: Item, current: int = 0, required: int = 0) -> void:
	item_data = new_item
	current_amount = current
	required_amount = required
	texture_rect.texture = item_data.icon
	if texture_rect.texture == null:
		push_warning("Item without icon:", item_data.display_name)
	count_label.text = str(current_amount, " / ", required_amount)

	if current_amount < required_amount:
		count_label.modulate = Color(1, 0.3, 0.3)
	else:
		count_label.modulate = Color(1, 1, 1)

func _make_custom_tooltip(_for_text: String) -> Object:
	if !item_data:
		return null
	var vbox: VBoxContainer = VBoxContainer.new()
	var title_label: Label = Label.new()
	title_label.text = item_data.display_name
	title_label.label_settings = LabelSettings.new()
	title_label.label_settings.font_size = 24
	vbox.add_child(title_label)
	if !item_data.description.is_empty():
		vbox.custom_minimum_size.x = 256.0
		var desc_label: Label = Label.new()
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.set_text.call_deferred(item_data.description)
		desc_label.modulate.a = 0.75
		vbox.add_child(desc_label)
	return vbox
