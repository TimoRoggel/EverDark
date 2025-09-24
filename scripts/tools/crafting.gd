class_name Crafting
extends Area2D




func _on_body_entered(body: Node2D) -> void:
	if body is PlayerController:
		print("Body Entered")


func _on_body_exited(body: Node2D) -> void:
	if body is PlayerController:
		print("Body Exited")
