class_name Crafting
extends Area2D

@export var crafting_ui: Crafting_UI = null
@export var crafting_table_item_id: int = 3

var hotbar : HBoxContainer
var is_interactable: bool = false
var player_ref: PlayerController = null
var crafting_input: InputComponent = null
var can_toggle: bool = true

func _ready() -> void:
	await get_tree().physics_frame
	self.process_mode = Node.PROCESS_MODE_ALWAYS
	
	if GameManager.player:
		crafting_input = GameManager.player.get_component(InputComponent)
		if crafting_input:
			crafting_input.pickup.connect(_on_pickup)
			
	if crafting_ui:
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

func _input(event: InputEvent) -> void:
	if crafting_ui.visible && can_toggle:
		if event.is_action_pressed("ui_cancel") or event.is_action_pressed("interact") or event.is_action_pressed("ui_menu"):
			close()

func _on_pickup() -> void:
	if crafting_ui.visible:
		close()
		
	if not is_interactable or not player_ref:
		return
		
	crafting_ui.visible = false
	is_interactable = false
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2.ONE * 0.1, 0.2)
	tween.play()
	await tween.finished
	var crafting_item = DataManager.get_resource_by_id("items", crafting_table_item_id)
	GameManager.player.inventory.add(crafting_item.id, 1)
	GameManager.player.inventory.set_held_item_id(crafting_item.id)
	GameManager.player.build.refresh_held_item()
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
	can_toggle = false
	await get_tree().physics_frame
	can_toggle = true

func close() -> void:
	crafting_ui.visible = false
	
	if hotbar:
		hotbar.visible = true
	
	get_tree().paused = false
	GameManager.paused = false
	
	GameManager.clear_active_ui()
	can_toggle = false
	await get_tree().physics_frame
	can_toggle = true
