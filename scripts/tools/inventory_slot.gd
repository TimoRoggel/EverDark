@tool
class_name InventorySlot extends PanelContainer

@export var inventory_item: InventoryItem = null:
	set(value):
		inventory_item = value
		_setup_item()
		item_changed.emit()

var index: int = 0
var icon: TextureRect = null
var label: Label = null
var hovered: bool = false
var dragging_item: InventoryItem = null
var input_only: bool = false
var output_only: bool = false
var filters: int = 0

signal pressed(item: InventoryItem)
signal item_dropped(item: InventoryItem)
signal item_changed

func _notification(what: int) -> void:
	if what == NOTIFICATION_DRAG_END:
		if !dragging_item:
			return
		if !is_drag_successful():
			item_dropped.emit(dragging_item)
		dragging_item = null

func _init() -> void:
	var vbox: VBoxContainer = VBoxContainer.new()
	vbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
	vbox.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(vbox)
	icon = TextureRect.new()
	icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	icon.size_flags_vertical = Control.SIZE_EXPAND_FILL
	icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(icon)
	label = Label.new()
	label.text = ""
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	vbox.add_child(label)
	mouse_entered.connect(func() -> void: hovered = true)
	mouse_exited.connect(func() -> void: hovered = false)

func _ready() -> void:
	_setup_item()
	custom_minimum_size = Vector2i.ONE * 48

func _unhandled_input(event: InputEvent) -> void:
	if !hovered:
		return
	if !is_instance_of(event, InputEventMouseButton):
		return
	if !event.pressed:
		return
	match event.button_index:
		MouseButton.MOUSE_BUTTON_LEFT:
			pressed.emit(inventory_item)
		MouseButton.MOUSE_BUTTON_WHEEL_UP:
			if dragging_item && inventory_item:
				dragging_item.quantity += 1
				remove_amount(1)
				_update_drag_preview()
				_setup_item()
		MouseButton.MOUSE_BUTTON_WHEEL_DOWN:
			if dragging_item && inventory_item:
				if dragging_item.quantity < 2:
					return
				if inventory_item.quantity >= inventory_item.item.stack_size:
					return
				dragging_item.quantity -= 1
				add_amount(1)
				_update_drag_preview()
				_setup_item()

func _get_drag_data(_pos: Vector2) -> Variant:
	if input_only:
		return {}
	if !inventory_item:
		return {}
	dragging_item = inventory_item.duplicate()
	if Input.is_key_pressed(KEY_SHIFT):
		inventory_item.quantity -= ceili(inventory_item.quantity / 2.0)
		dragging_item.quantity -= inventory_item.quantity
	elif Input.is_key_pressed(KEY_CTRL):
		inventory_item.quantity -= 1
		dragging_item.quantity = 1
	else:
		inventory_item.quantity = 0
	if inventory_item.quantity < 1:
		inventory_item = null
	_update_drag_preview()
	_setup_item()
	return { "slot": self, "item": dragging_item }

func _update_drag_preview() -> void:
	if !dragging_item:
		return
	var drag_icon: TextureRect = TextureRect.new()
	drag_icon.texture = dragging_item.item.icon
	drag_icon.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
	drag_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	drag_icon.size = Vector2i.ONE * 32
	var drag_label: Label = Label.new()
	drag_label.text = str(dragging_item.quantity, "x")
	drag_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	drag_label.position += Vector2(8.0, 32.0)
	drag_icon.add_child(drag_label)
	set_drag_preview(drag_icon)

func _can_drop_data(_pos: Vector2, data: Variant):
	if output_only:
		return false
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if !data.has("slot"):
		return false
	if !data.has("item"):
		return false
	if !is_instance_of(data.get("item"), InventoryItem):
		return false
	if !data.get("item").item:
		return false
	if !_is_valid_item(data.get("item").item):
		return false
	if inventory_item && inventory_item.item && inventory_item.quantity >= inventory_item.item.stack_size:
		return false
	return inventory_item == null || data.get("item").item == inventory_item.item

func _drop_data(_pos: Vector2, data: Variant) -> void:
	if !data:
		return
	var i_item: InventoryItem = data.get("item")
	var i_slot: InventorySlot = data.get("slot")
	if !inventory_item:
		inventory_item = i_item
	elif inventory_item.item == i_item.item:
		var result: Dictionary[String, int] = merge(i_item)
		if result["remainder"] > 0:
			i_slot.inventory_item = InventoryItem.new(i_item.item, result["remainder"])
			i_slot._setup_item()
	_setup_item()

func _is_valid_item(item: Item) -> bool:
	return item.flags & filters == filters

func _setup_item() -> void:
	if inventory_item:
		icon.texture = inventory_item.item.icon
		label.text = str(inventory_item.quantity, "x")
		tooltip_text = inventory_item.item.display_name
	else:
		icon.texture = null
		label.text = ""
		tooltip_text = ""

func add_amount(amount: int = 0) -> void:
	if !inventory_item:
		return
	inventory_item.quantity += amount

func remove_amount(amount: int = 0) -> void:
	if !inventory_item:
		return
	inventory_item.quantity -= amount
	if inventory_item.quantity < 1:
		inventory_item = null

func is_full() -> bool:
	if !inventory_item:
		return false
	return inventory_item.is_full()

func merge(other: InventoryItem, custom_amount: int = -1) -> Dictionary[String, int]:
	var status: int = OK
	var remainder: int = 0
	if !_is_valid_item(other.item):
		status = FAILED
	else:
		if !inventory_item:
			if custom_amount < 0:
				custom_amount = other.quantity
			remainder = max(0, custom_amount - other.item.stack_size)
			inventory_item = InventoryItem.new(other.item, custom_amount - remainder)
		else:
			if other.item != inventory_item.item:
				status = FAILED
			else:
				var max_stack: int = inventory_item.item.stack_size
				if custom_amount < 0:
					custom_amount = other.quantity
				if inventory_item.quantity + custom_amount > max_stack:
					remainder = inventory_item.quantity + custom_amount - max_stack
					inventory_item.quantity = max_stack
				else:
					inventory_item.quantity += custom_amount
	return { "status": status, "remainder": remainder }
