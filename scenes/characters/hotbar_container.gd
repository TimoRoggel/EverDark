extends HBoxContainer

@export var inventory: InventoryContainer

var slots_per_row: int
var currently_selected_slot: int = 0
var is_active: bool = true

func _ready() -> void:
	if inventory:
		slots_per_row = roundi(inventory.slots / float(inventory.rows))
		add_slots()
		inventory.updated.connect(update_hotbar)

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop_item") and is_active:
		var current_item: InventoryItem = inventory.get_slots()[currently_selected_slot].inventory_item
		if current_item:
			print("Dropped: ", inventory.get_slots()[currently_selected_slot].inventory_item)
		else:
			print("Empty slot")
	elif is_instance_of(event, InputEventMouseButton):
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				currently_selected_slot = posmod(currently_selected_slot - 1, slots_per_row)
				select_slot(currently_selected_slot)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				currently_selected_slot = posmod(currently_selected_slot + 1, slots_per_row)
				select_slot(currently_selected_slot)

func add_slots():
	if inventory && self.get_child_count() == 0:
		for i in slots_per_row:
			var slot_texture: TextureButton = create_slot()
			var item_texture: TextureRect = create_item_texture()
			var amount_label: Label = create_amount_label()
			slot_texture.add_child(item_texture)
			slot_texture.add_child(amount_label)
			self.add_child(slot_texture)
		select_slot(currently_selected_slot)
		
func create_slot() -> TextureButton:
	var slot_texture: TextureButton = TextureButton.new()
	slot_texture.texture_normal = preload("res://graphics/ui_icons/hotbar_slot_normal.png")
	slot_texture.texture_focused = preload("res://graphics/ui_icons/hotbar_slot_focus.png")
	return slot_texture
	
func create_item_texture() -> TextureRect:
	var item_texture: TextureRect = TextureRect.new()
	item_texture.stretch_mode = TextureRect.STRETCH_KEEP
	item_texture.anchor_left = 0.0
	item_texture.anchor_top = 0.0
	item_texture.anchor_right = .8
	item_texture.anchor_bottom = .8
	return item_texture
	
func create_amount_label() -> Label:
	var amount_label: Label = Label.new()
	amount_label.text = ""
	amount_label.anchor_left = 0.0
	amount_label.anchor_top = 0.0
	amount_label.anchor_right = 1.0
	amount_label.anchor_bottom = 1.0
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return amount_label
		
func update_hotbar():
	if inventory:
		var inventory_slots: Array[InventorySlot] = inventory.get_slots()
		for i in slots_per_row:
			var current_slot: TextureButton = self.get_child(i)
			var item_slot: InventorySlot = inventory_slots[i]
			if item_slot.is_empty():
				current_slot.get_child(1).text = ""
				current_slot.get_child(0).texture = null
			else:
				var item_icon: Texture2D = inventory.get_slots()[i].inventory_item.item.icon
				var quantity: int = inventory.get_slots()[i].inventory_item.quantity
				current_slot.get_child(1).text = str(quantity) + "x"
				current_slot.get_child(0).texture = item_icon
				scale_texture_rect(current_slot.get_child(0), current_slot.size*.8)
		
func select_slot(slot_number):
	var slot_node: TextureButton = self.get_child(slot_number)
	slot_node.grab_focus()
	update_currently_selected_slot()

func scale_texture_rect(texture_rect: TextureRect, parent_size: Vector2):
	var tex_size: Vector2 = texture_rect.texture.get_size()
	var tex_scale: int = min(roundi(parent_size.x / tex_size.x), roundi(parent_size.y / tex_size.y))
	texture_rect.scale = Vector2(tex_scale, tex_scale)
	
func update_currently_selected_slot():
	for child in self.get_children():
		if child.has_focus():
			if currently_selected_slot != child.get_index():
				currently_selected_slot = child.get_index()
			break
