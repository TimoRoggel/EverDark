class_name Chest
extends Area2D

const CHEST_CLOSED = preload("uid://dh0rj8oyd78hu")
const CHEST_OPEN = preload("uid://bt5l56duf4ya0")

@export var chest_inventory: InventoryContainer = null
@export var chest_item_id: int = 4
@export var sprite_chest: Sprite2D

var is_interactable: bool = false
var player_ref: PlayerController = null
var player_ref_inventory: InventoryComponent = null
var chest_input: InputComponent = null

func _ready() -> void:
	chest_input = GameManager.player.get_component(InputComponent)
	chest_input.pickup.connect(_on_pickup)

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
	if is_interactable and player_ref:
		if Input.is_action_just_pressed("interact"):
			var items_to_drop: Array[InventoryItem] = chest_inventory.get_items()
			for item: InventoryItem in items_to_drop:
				var leftover: int = player_ref_inventory.container.add(item.item.id, item.quantity)
				if leftover > 0:
					var dropped_item: DroppedItem2D = DroppedItem2D.new()
					dropped_item.item = item.item
					get_parent().add_child(dropped_item)
					dropped_item.global_position = player_ref.global_position

			for slot: InventorySlot in chest_inventory.get_slots():
				slot.inventory_item = null
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

	for item in chest_inventory.get_items():
		var leftover = player_ref_inventory.container.add(item.item.id, item.quantity)
		if leftover > 0:
			var dropped_item: DroppedItem2D = DroppedItem2D.new()
			dropped_item.item = item.item
			dropped_item.amount = leftover
			get_parent().add_child(dropped_item)
			dropped_item.global_position = player_ref.global_position
			dropped_item.timeout()

	var chest_item = DataManager.get_resource_by_id("items", chest_item_id)
	var leftover_chest = player_ref_inventory.add(chest_item.id, 1)
	player_ref_inventory.set_held_item_id(chest_item.id)

	if leftover_chest > 0:
		var dropped_chest: DroppedItem2D = DroppedItem2D.new()
		dropped_chest.item = chest_item
		dropped_chest.amount = leftover_chest
		get_parent().add_child(dropped_chest)
		dropped_chest.global_position = player_ref.global_position
		dropped_chest.timeout()

	for slot in chest_inventory.get_slots():
		slot.inventory_item = null
	chest_inventory.visible = false
	player_ref_inventory.container.visible = false

	queue_free()
	player_ref.get_component(BuildComponent).refresh_held_item()
