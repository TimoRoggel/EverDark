class_name Crafting
extends Area2D

@export var crafting_ui: Crafting_UI = null
@export var crafting_table_item_id: int = 3

var is_interactable : bool = false
var player_ref : PlayerController = null
var crafting_input: InputComponent = null

func _ready() -> void:
	crafting_input = GameManager.player.get_component(InputComponent)
	crafting_input.pickup.connect(_on_pickup)

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		player_ref = body
		is_interactable = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		player_ref = null
		is_interactable = false
		crafting_ui.visible = false

func _process(_delta: float) -> void:
	if is_interactable and player_ref:
		if Input.is_action_just_pressed("ui"): 
			toggle_ui(player_ref)

func _on_pickup() -> void:
	if not is_interactable or not player_ref:
		return
	var crafting_item = DataManager.get_resource_by_id("items", crafting_table_item_id)
	player_ref.get_component(InventoryComponent).add(crafting_item.id, 1)
	player_ref.get_component(InventoryComponent).set_held_item_id(crafting_item.id)
	crafting_ui.visible = false
	queue_free()

func toggle_ui(controller: PlayerController) -> void:
	if controller:
		crafting_ui.inventory = controller.get_component(InventoryComponent)
	crafting_ui.visible = !crafting_ui.visible
