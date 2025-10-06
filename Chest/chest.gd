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
		if Input.is_action_just_pressed("open"): 
			chest_inventory.visible = !chest_inventory.visible
			player_ref_inventory.container.visible = chest_inventory.visible

		if Input.is_action_just_pressed("interact"):
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

	if chest_inventory.visible:
		sprite_chest.texture = CHEST_OPEN
	else:
		sprite_chest.texture = CHEST_CLOSED
