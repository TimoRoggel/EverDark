extends HBoxContainer

const ITEM_MATERIAL = preload("uid://cxwuww81e8unb")

@export var inventory: InventoryContainer
@export var inventory_component: InventoryComponent

var hotbar_slots: int = 5 
var currently_selected_slot: int = 0
var is_active: bool = true
var hotbar_just_emptied: bool = false

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

# Hotbar.gd

func _input(event: InputEvent) -> void:
	if not is_active:
		return
	
	if event.is_action_pressed("drop_item"):
		if inventory:
			var slots = inventory.get_slots()
			if currently_selected_slot < slots.size():
				var current_slot: InventorySlot = slots[currently_selected_slot]
				if current_slot and current_slot.inventory_item:
					var current_item: Item = current_slot.inventory_item.item
					if current_item:
						if GameManager.is_player_nearby_hole and current_item.id != 1:
							return
					current_slot.drop_item_manually(Input.is_key_pressed(KEY_CTRL))
					update_held_item()

	if is_instance_of(event, InputEventMouseButton):
		if event.is_pressed():
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				currently_selected_slot = posmod(currently_selected_slot - 1, hotbar_slots)
				select_slot(currently_selected_slot)
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				currently_selected_slot = posmod(currently_selected_slot + 1, hotbar_slots)
				select_slot(currently_selected_slot)

	if event is InputEventKey and event.pressed:
		if event.keycode >= KEY_1 and event.keycode <= KEY_9:
			var slot_index = event.keycode - KEY_1
			if slot_index < hotbar_slots:
				select_slot(slot_index)

func _process(_delta: float) -> void:
	update_hotbar()

func lock_slot(index: int) -> void:
	if !inventory:
		return
	var slots = inventory.get_slots()
	if index >= slots.size():
		return
	var slot: InventorySlot = slots[index]
	if slot.inventory_item:
		slot.inventory_item.locked = !slot.inventory_item.locked
		popup_animation(get_child(index).get_child(0))

func add_slots() -> void:
	if inventory && self.get_child_count() == 0:
		for i: int in hotbar_slots:
			var slot_texture: HotbarTextureButton = create_slot(i)
			var item_texture: TextureRect = create_item_texture()
			var amount_label: Label = create_amount_label()
			var key_label: Label = create_key_index_label(i)
			#var key_texxture: TextureRect = create_index_texture()
			slot_texture.add_child(item_texture)
			slot_texture.add_child(amount_label)
			#key_label.add_child(key_texxture)
			slot_texture.add_child(key_label)
			add_child(slot_texture)

func create_slot(index: int = 0) -> HotbarTextureButton:
	var slot_texture: HotbarTextureButton = HotbarTextureButton.new()
	slot_texture.texture_normal = preload("res://graphics/32x32_inventory_HUD_01_transp.png")
	slot_texture.texture_focused = preload("res://graphics/ui_icons/hotbar_slot_focus.png")
	slot_texture.container = self
	slot_texture.index = index
	#slot_texture.mouse_filter = Control.MOUSE_FILTER_IGNORE
	slot_texture.focus_mode = Control.FOCUS_ACCESSIBILITY
	return slot_texture

func create_item_texture() -> TextureRect:
	var item_texture: TextureRect = TextureRect.new()
	item_texture.stretch_mode = TextureRect.STRETCH_KEEP
	item_texture.anchor_left = 0.0
	item_texture.anchor_top = 0.0
	item_texture.anchor_right = 0.8
	item_texture.anchor_bottom = 0.8
	item_texture.material = ITEM_MATERIAL.duplicate()
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
	
func create_key_index_label(index: int) -> Label:
	var key_label := Label.new()
	key_label.text = str(index + 1)
	key_label.anchor_left = 0.0
	key_label.anchor_top = -0.5
	key_label.anchor_right = 1.0
	key_label.anchor_bottom = 0.0
	key_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	key_label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	key_label.add_theme_color_override("font_color", Color.WHITE)
	return key_label
	
func create_index_texture() -> TextureRect:
	var item_texture: TextureRect = TextureRect.new()
	item_texture.texture = preload("res://map/Art Assets/Player HUD/Small_keybind.png")
	item_texture.z_index = -1
	item_texture.anchor_left = 0.0
	item_texture.scale = Vector2(0.2, 0.2)
	item_texture.set_anchors_preset(Control.PRESET_CENTER)
	item_texture.ready.connect(func():
		item_texture.pivot_offset = item_texture.size / 2
	)
	return item_texture

func update_hotbar() -> void:
	if !inventory:
		return
	
	var items: Array[InventoryItem] = inventory.get_items()

	var inventory_slots: Array[InventorySlot] = inventory.get_slots()
	for i: int in hotbar_slots:
		var slot_node: HotbarTextureButton = get_child(i)
		#var inventory_pos = (inventory_slots.size()-(slots_per_row))+i
		if i < inventory_slots.size() && inventory_slots[i].inventory_item:
			var item_icon: Texture2D = inventory_slots[i].inventory_item.item.icon
			var quantity: int = inventory_slots[i].inventory_item.quantity
			var slot: TextureRect = slot_node.get_child(0)
			var quantity_label: Label = slot_node.get_child(1)
			if slot.texture != item_icon:
				popup_animation.call_deferred(slot)
			slot_node.item = inventory_slots[i].inventory_item.item
			if inventory_slots[i].inventory_item.item.stack_size > 1:
				if !quantity_label.text.contains(str(quantity)):
					popup_animation.call_deferred(slot)
				quantity_label.text = str(quantity) + "x"
			else:
				quantity_label.text = ""
			if inventory_slots[i].inventory_item.locked:
				quantity_label.text = "🔒 " + quantity_label.text
			slot.texture = item_icon
			scale_texture_rect(slot, slot_node.size * 0.8)
			hotbar_just_emptied = false
		if !items:
			if !hotbar_just_emptied:
				for slot: Node in get_children():
					if is_instance_of(slot, HotbarTextureButton):
						slot.get_child(0).texture = null
						slot.get_child(1).text = ""
						slot_node.item = null
				hotbar_just_emptied = true
		elif !inventory_slots[i].inventory_item:
			slot_node.item = null
			slot_node.get_child(0).texture = null
			slot_node.get_child(1).text = ""

func popup_animation(item_icon: Control) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_method(scale_icon.bind(item_icon), Vector2.ONE, Vector2.ONE * 1.25, 0.05)
	tween.tween_method(scale_icon.bind(item_icon), Vector2.ONE * 1.25, Vector2.ONE * 0.75, 0.05)
	tween.tween_method(scale_icon.bind(item_icon), Vector2.ONE * 0.75, Vector2.ONE, 0.05)
	tween.play()

func scale_icon(s: Vector2, item_icon: Control) -> void:
	item_icon.material.set_shader_parameter("scale", s)

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
