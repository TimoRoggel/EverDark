class_name Chest
extends Area2D

const CHEST_CLOSED = preload("uid://dh0rj8oyd78hu")
const CHEST_OPEN = preload("uid://bt5l56duf4ya0")
const CLOSE_SOUND = preload("uid://wy072etgvvd1") 

@export var chest_inventory: InventoryContainer = null
@export var chest_item_id: int = 4
@export var sprite_chest: Sprite2D
@export var open_close_sound: AudioStreamPlayer2D = null

var is_interactable: bool = false
var player_ref: PlayerController = null
var player_ref_inventory: InventoryComponent = null
var chest_input: InputComponent = null

func _ready() -> void:
	await get_tree().physics_frame
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	chest_inventory.process_mode = Node.PROCESS_MODE_ALWAYS
	chest_input = GameManager.player.get_component(InputComponent)
	chest_input.pickup.connect(_on_pickup)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_ref = body
		player_ref_inventory = player_ref.get_component(InventoryComponent)
		is_interactable = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		if chest_inventory.visible:
			close()
		
		if player_ref:
			player_ref.hotbar.visible = true
			player_ref.inventory.container.visible = false
		player_ref = null
		player_ref_inventory = null
		is_interactable = false
		chest_inventory.visible = false

func _process(_delta: float) -> void:
	if chest_inventory.visible:
		sprite_chest.texture = CHEST_OPEN
	else:
		sprite_chest.texture = CHEST_CLOSED

func open() -> void:
	chest_inventory.visible = true
	if player_ref:
		player_ref.hotbar.visible = false
		player_ref_inventory.container.visible = true
	GameManager.paused = true
	get_tree().paused = true
	GameManager.set_active_ui(self)

func close() -> void:
	chest_inventory.visible = false
	if player_ref:
		player_ref.hotbar.visible = true
		player_ref_inventory.container.visible = false

	if open_close_sound:
		open_close_sound.stream = CLOSE_SOUND
		open_close_sound.play()
		
	GameManager.paused = false
	get_tree().paused = false
	GameManager.clear_active_ui()

func _on_pickup() -> void:
	if not is_interactable or not player_ref:
		return

	if chest_inventory.visible:
		close()

	for item in chest_inventory.get_items():
		var leftover = player_ref_inventory.container.add(item.item.id, item.quantity)
		if leftover > 0:
			DroppedItem2D.drop(item.item.id, leftover, player_ref.global_position)

	var chest_item = DataManager.get_resource_by_id("items", chest_item_id)
	var leftover_chest = player_ref_inventory.add(chest_item.id, 1)
	player_ref_inventory.set_held_item_id(chest_item.id)

	if leftover_chest > 0:
		DroppedItem2D.drop(chest_item_id, leftover_chest, player_ref.global_position)

	for slot in chest_inventory.get_slots():
		slot.inventory_item = null
	
	chest_inventory.visible = false
	player_ref_inventory.container.visible = false
	WorldStateSaver.placed_items.erase(name)

	queue_free()
	player_ref.get_component(BuildComponent).refresh_held_item()
