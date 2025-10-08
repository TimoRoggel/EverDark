class_name Crafting
extends Area2D

@export var crafting_ui: Crafting_UI = null
@export var crafting_table_item_id: int = 1

var is_interactable : bool = false
var player_ref : PlayerController = null

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
		if Input.is_action_just_pressed("open"): 
			crafting_ui.inventory = player_ref.get_component(InventoryComponent)
			crafting_ui.visible = !crafting_ui.visible
