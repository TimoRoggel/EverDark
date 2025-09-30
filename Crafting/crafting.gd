class_name Crafting
extends Area2D

@export var crafting_ui: Crafting_UI = null

var is_interactable : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		crafting_ui.inventory = body.get_component(InventoryComponent)
		crafting_ui.visible = true
		is_interactable = true

func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		crafting_ui.visible = false
		is_interactable = false
