extends HBoxContainer

@export var inventory: InventoryContainer
@export var inventory_component: InventoryComponent  

var hotbar_slots: int = 3 
var currently_selected_slot: int = 0
var is_active: bool = true
var hotbar_just_emptied: bool = false
var slots_per_row: int = 3

func _ready() -> void:
	if inventory:
		inventory.updated.connect(update_held_item)
	add_slots()
	update_hotbar()
	update_currently_selected_slot()
	select_slot(currently_selected_slot)
	visibility_changed.connect(_on_visibility_changed)

func _on_visibility_changed() -> void:
	if !visible:
		return
	update_hotbar()
	update_currently_selected_slot()
	select_slot(currently_selected_slot)

func _input(event: InputEvent) -> void:
	if not is_active:
		return

	# Drop item
	#if event.is_action_pressed("drop_item"):
		#var current_item = inventory.get_slots()[currently_selected_slot].inventory_item
		#if current_item:
			#print("Dropped: ", current_item)
		#else:
			#print("Empty slot")
	if is_instance_of(event, InputEventMouseButton):
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				currently_selected_slot = posmod(currently_selected_slot - 1, hotbar_slots)
				select_slot(currently_selected_slot)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				currently_selected_slot = posmod(currently_selected_slot + 1, hotbar_slots)
				select_slot(currently_selected_slot)

func _process(_delta: float) -> void:
	update_hotbar()

func add_slots() -> void:
	if inventory && self.get_child_count() == 0:
		for i: int in slots_per_row:
			var slot_texture: TextureButton = create_slot()
			var item_texture: TextureRect = create_item_texture()
			var amount_label: Label = create_amount_label()
			slot_texture.add_child(item_texture)
			slot_texture.add_child(amount_label)
			add_child(slot_texture)

func create_slot() -> TextureButton:
	var slot_texture: TextureButton = TextureButton.new()
	slot_texture.texture_normal = preload("res://graphics/32x32_inventory_HUD_01_transp.png")
	slot_texture.texture_focused = preload("res://graphics/ui_icons/hotbar_slot_focus.png")
	slot_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_texture.focus_mode = Control.FOCUS_CLICK
	return slot_texture

func create_item_texture() -> TextureRect:
	var item_texture: TextureRect = TextureRect.new()
	item_texture.stretch_mode = TextureRect.STRETCH_KEEP
	item_texture.anchor_left = 0.0
	item_texture.anchor_top = 0.0
	item_texture.anchor_right = 0.8
	item_texture.anchor_bottom = 0.8
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

func update_hotbar() -> void:
	if !inventory:
		return
	
	var items: Array[InventoryItem] = inventory.get_items()

	var inventory_slots: Array[InventorySlot] = inventory.get_slots()
	for i: int in hotbar_slots:
		var slot_node: TextureButton = get_child(i)
		#var inventory_pos = (inventory_slots.size()-(slots_per_row))+i
		if i < inventory_slots.size() && inventory_slots[i].inventory_item:
			var item_icon: Texture2D = inventory_slots[i].inventory_item.item.icon
			var quantity: int = inventory_slots[i].inventory_item.quantity
			slot_node.get_child(1).text = str(quantity) + "x"
			slot_node.get_child(0).texture = item_icon
			scale_texture_rect(slot_node.get_child(0), slot_node.size * 0.8)
			hotbar_just_emptied = false
		if !items:
			if !hotbar_just_emptied:
				for slot: Node in get_children():
					if is_instance_of(slot, TextureButton):
						slot.get_child(0).texture = null
						slot.get_child(1).text = ""
				hotbar_just_emptied = true
		elif !inventory_slots[i].inventory_item:
				slot_node.get_child(0).texture = null
				slot_node.get_child(1).text = ""
	
func scale_texture_rect(texture_rect: TextureRect, parent_size: Vector2) -> void:
	if texture_rect.texture:
		var tex_size: Vector2 = texture_rect.texture.get_size()
		var tex_scale: int = min(roundi(parent_size.x / tex_size.x), roundi(parent_size.y / tex_size.y))
		texture_rect.scale = Vector2(tex_scale, tex_scale)

func select_slot(slot_number: int) -> void:
	if slot_number >= 0 && slot_number < get_child_count():
		var slot_node: Node = get_child(slot_number)
		slot_node.grab_focus()
		currently_selected_slot = slot_number
		update_held_item()
				
	update_currently_selected_slot()
	
func substract_item():
	if inventory_component && inventory:
		var selected_slot: InventorySlot = inventory.get_slots()[currently_selected_slot]
		var selected_item: InventoryItem = selected_slot.inventory_item
		inventory.remove(selected_item.item.id, 1)
				
func get_selected_item_name():
	var selected_slot: InventorySlot = inventory.get_slots()[currently_selected_slot]
	var selected_item: InventoryItem = selected_slot.inventory_item
	if selected_item:
		return selected_item.item.display_name

func update_currently_selected_slot() -> void:
	for child: Node in self.get_children():
		if child.has_focus():
			if currently_selected_slot != child.get_index():
				currently_selected_slot = child.get_index()
			break

func update_held_item() -> void:
	if !inventory_component:
		return
	if !inventory:
		return
	var selected_slot: InventorySlot = inventory.get_slots()[currently_selected_slot]
	var selected_item: InventoryItem = selected_slot.inventory_item
	if selected_item && selected_item.item:
		inventory_component.held_item = selected_item.item.id
	else:
		inventory_component.held_item = -1
