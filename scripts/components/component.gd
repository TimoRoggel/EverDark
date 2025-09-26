@abstract @icon("res://graphics/node_icons/component.png")
class_name Component extends Node2D

var updates_in_physics: bool = true
var controller: CharacterController = null

func initialize(_controller: CharacterController) -> void:
	controller = _controller
	_enter()

@abstract func _enter() -> void

@abstract func _update(_delta: float) -> void

@abstract func _exit() -> void
