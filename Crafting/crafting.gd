class_name Crafting
extends Area2D


var is_interactable : bool = false

func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		is_interactable = true


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		is_interactable = false
