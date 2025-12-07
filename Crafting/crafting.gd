class_name Crafting
extends Area2D

@export var crafting_ui: Crafting_UI = null
@export var crafting_table_item_id: int = 3

var hotbar : HBoxContainer

var is_interactable: bool = false
var player_ref: PlayerController = null
var crafting_input: InputComponent = null

func _ready() -> void:
	await get_tree().physics_frame
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	crafting_input = GameManager.player.get_component(InputComponent)
	crafting_input.pickup.connect(_on_pickup)
	crafting_ui.close_requested.connect(close)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_ref = body
		is_interactable = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		if not crafting_ui.visible:
			player_ref = null
		is_interactable = false
		if hotbar and not crafting_ui.visible:
			hotbar.visible = true

func _process(_delta: float) -> void:
	if crafting_ui.visible:
		if Input.is_action_just_pressed("ui") or Input.is_action_just_pressed("interact"):
			close()

func _on_pickup() -> void:
	if crafting_ui.visible:
		close()
		
	if not is_interactable or not player_ref:
		return
		
	var crafting_item = DataManager.get_resource_by_id("items", crafting_table_item_id)
	player_ref.inventory.add(crafting_item.id, 1)
	player_ref.inventory.set_held_item_id(crafting_item.id)
	player_ref.build.refresh_held_item()
	crafting_ui.visible = false
	WorldStateSaver.placed_items.erase(name)
	queue_free()

func open() -> void:
	if not player_ref:
		player_ref = GameManager.player
		
	if player_ref:
		crafting_ui.inventory = player_ref.inventory
		if player_ref.hotbar:
			hotbar = player_ref.hotbar
			hotbar.visible = false
			
	crafting_ui.visible = true
	
	get_tree().paused = true
	GameManager.paused = true
	
	GameManager.set_active_ui(self)

func close() -> void:
	crafting_ui.visible = false
	
	if hotbar:
		hotbar.visible = true
	
	get_tree().paused = false
	GameManager.paused = false
	
	GameManager.clear_active_ui()
