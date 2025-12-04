class_name WorldState extends Node

func _ready() -> void:
	SaveSystem.track("world_state", WorldStateSaver.get_world_state, WorldStateSaver.set_world_state, {})
