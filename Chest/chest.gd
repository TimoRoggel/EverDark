class_name Chest
extends Area2D

const CHEST_CLOSED = preload("uid://dh0rj8oyd78hu")
const CHEST_OPEN = preload("uid://bt5l56duf4ya0")

@export var chest_inventory: InventoryContainer = null
@export var chest_item_id: int = 1
@export var sprite_chest: Sprite2D

var is_interactable: bool = false
var player_ref: PlayerController = null
var player_ref_inventory: InventoryComponent = null
var chest_input: InputComponent = null

func _ready() -> void:
	chest_input = InputComponent.new()
	add_child(chest_input)
	chest_input.ui.connect(_on_ui)
	chest_input.pickup.connect(_on_pickup)
	chest_input.place.connect(_on_place)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_ref = body
		player_ref_inventory = player_ref.get_component(InventoryComponent)
		is_interactable = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_ref = null
		player_ref_inventory = null
		is_interactable = false
		chest_inventory.visible = false

func _process(_delta: float) -> void:
	if chest_inventory.visible:
		sprite_chest.texture = CHEST_OPEN
	else:
		sprite_chest.texture = CHEST_CLOSED

func _on_ui() -> void:
	if not is_interactable or not player_ref:
		return
	chest_inventory.visible = !chest_inventory.visible
	player_ref_inventory.container.visible = chest_inventory.visible

func _on_pickup() -> void:
	if not is_interactable or not player_ref:
		return
	var items_to_drop = chest_inventory.get_items()
	for item in items_to_drop:
		var leftover = player_ref_inventory.container.add(item.item.id, item.quantity)
		if leftover > 0:
			var dropped_item: DroppedItem2D = DroppedItem2D.new()
			dropped_item.item = item.item
			dropped_item.quantity = leftover
			get_parent().add_child(dropped_item)
			dropped_item.global_position = player_ref.global_position
	for slot in chest_inventory.get_slots():
		slot.inventory_item = null
	chest_inventory.visible = false
	player_ref_inventory.container.visible = false
	player_ref_inventory.set_held_item_id(chest_item_id)
	queue_free()

func _on_place(mouse_pos: Vector2) -> void:
	if not player_ref or not player_ref_inventory:
		return
	if player_ref_inventory.get_held_item_id() != chest_item_id:
		return
	var new_chest: Chest = Chest.new()
	get_parent().add_child(new_chest)
	new_chest.global_position = mouse_pos
	new_chest.chest_inventory = chest_inventory.duplicate()
	new_chest.sprite_chest = sprite_chest.duplicate()
	new_chest.chest_item_id = chest_item_id
	player_ref_inventory.set_held_item_id(0)
