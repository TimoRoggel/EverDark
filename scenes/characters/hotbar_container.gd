extends HBoxContainer

@export var inventory: InventoryContainer
@export var inventory_component: InventoryComponent  

var hotbar_slots: int = 10 
var currently_selected_slot: int = 0
var is_active: bool = true

func _ready() -> void:
	add_slots()
	select_slot(currently_selected_slot)

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	# Drop item
	if event.is_action_pressed("drop_item"):
		var current_item = inventory.get_slots()[currently_selected_slot].inventory_item
		if current_item:
			print("Dropped: ", current_item)
		else:
			print("Empty slot")

	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			currently_selected_slot = posmod(currently_selected_slot - 1, hotbar_slots)
			select_slot(currently_selected_slot)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			currently_selected_slot = posmod(currently_selected_slot + 1, hotbar_slots)
			select_slot(currently_selected_slot)

func _process(_delta: float) -> void:
	update_hotbar()

func add_slots():
	if inventory and get_child_count() == 0:
		for i in range(hotbar_slots):
			var slot_texture = create_slot()
			var item_texture = create_item_texture()
			var amount_label = create_amount_label()
			slot_texture.add_child(item_texture)
			slot_texture.add_child(amount_label)
			add_child(slot_texture)

func create_slot() -> TextureButton:
	var slot_texture = TextureButton.new()
	slot_texture.texture_normal = preload("res://graphics/ui_icons/hotbar_slot_normal.png")
	slot_texture.texture_focused = preload("res://graphics/ui_icons/hotbar_slot_focus.png")
	return slot_texture

func create_item_texture() -> TextureRect:
	var item_texture = TextureRect.new()
	item_texture.stretch_mode = TextureRect.STRETCH_KEEP
	item_texture.anchor_left = 0.0
	item_texture.anchor_top = 0.0
	item_texture.anchor_right = 0.8
	item_texture.anchor_bottom = 0.8
	return item_texture

func create_amount_label() -> Label:
	var amount_label = Label.new()
	amount_label.text = ""
	amount_label.anchor_left = 0.0
	amount_label.anchor_top = 0.0
	amount_label.anchor_right = 1.0
	amount_label.anchor_bottom = 1.0
	amount_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	amount_label.vertical_alignment = VERTICAL_ALIGNMENT_BOTTOM
	return amount_label

func update_hotbar():
	if not inventory:
		return

	var inventory_slots = inventory.get_slots()
	for i in range(hotbar_slots):
		var slot_node = get_child(i)
		if i < inventory_slots.size() and inventory_slots[i].inventory_item:
			var item_icon = inventory_slots[i].inventory_item.item.icon
			var quantity = inventory_slots[i].inventory_item.quantity
			slot_node.get_child(1).text = str(quantity) + "x"
			slot_node.get_child(0).texture = item_icon
			scale_texture_rect(slot_node.get_child(0), slot_node.size * 0.8)
		else:
			slot_node.get_child(1).text = ""
			slot_node.get_child(0).texture = null

func scale_texture_rect(texture_rect: TextureRect, parent_size: Vector2):
	if texture_rect.texture:
		var tex_size = texture_rect.texture.get_size()
		var tex_scale = min(roundi(parent_size.x / tex_size.x), roundi(parent_size.y / tex_size.y))
		texture_rect.scale = Vector2(tex_scale, tex_scale)

func select_slot(slot_number: int):
	if slot_number >= 0 and slot_number < get_child_count():
		var slot_node = get_child(slot_number)
		slot_node.grab_focus()
		currently_selected_slot = slot_number
	print(inventory.get_slots()[currently_selected_slot].inventory_item)
