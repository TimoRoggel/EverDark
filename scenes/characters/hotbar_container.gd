extends HBoxContainer

@export var inventory: InventoryContainer

var slots_per_row: int

var currently_selected_slot: int = 0

func _ready() -> void:
	if inventory:
		slots_per_row = inventory.slots/inventory.rows
		
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_left"):
		print(inventory.get_slots()[0].inventory_item)
	
func _process(delta: float) -> void:
	add_slots()
	update_hotbar()
	
func add_slots():
	if inventory && self.get_child_count() == 0:
		for i in slots_per_row:
			var slot_texture = TextureButton.new()
			slot_texture.texture_normal = preload("res://graphics/ui_icons/hotbar_slot_normal.png")
			slot_texture.texture_focused = preload("res://graphics/ui_icons/hotbar_slot_focus.png")
			var item_texture = TextureRect.new()
			item_texture.stretch_mode = TextureRect.STRETCH_KEEP
			item_texture.anchor_left = 0.0
			item_texture.anchor_top = 0.0
			item_texture.anchor_right = .8
			item_texture.anchor_bottom = .8
			var amount_label = Label.new()
			amount_label.text = str(0) + "x"
			amount_label.anchor_left = 0.0
			amount_label.anchor_top = 0.0
			amount_label.anchor_right = 1.0
			amount_label.anchor_bottom = 1.0
			amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
			slot_texture.add_child(item_texture)
			slot_texture.add_child(amount_label)
			self.add_child(slot_texture)
		select_slot(currently_selected_slot)
		
func update_hotbar():
	if inventory:
		if inventory.get_items():
			var inventory_slots = inventory.get_slots()
			for i in slots_per_row:
				var current_slot = self.get_child(i)
				if inventory_slots[i].inventory_item:
					var item_icon = inventory.get_slots()[i].inventory_item.item.icon
					var quantity = inventory.get_slots()[i].inventory_item.quantity
					current_slot.get_child(1).text = str(quantity) + "x"
					current_slot.get_child(0).texture = item_icon
					scale_texture_rect(current_slot.get_child(0), current_slot.size*.8)
				else:
					current_slot.get_child(1).text = str(0) + "x"
					current_slot.get_child(0).texture = null
		
func select_slot(slot_number):
	var slot_node = self.get_child(slot_number)
	slot_node.grab_focus()

func scale_texture_rect(texture_rect: TextureRect, parent_size: Vector2):
	var tex_size = texture_rect.texture.get_size()
	var scale = min(parent_size.x / tex_size.x, parent_size.y / tex_size.y)
	texture_rect.scale = Vector2(scale, scale)
