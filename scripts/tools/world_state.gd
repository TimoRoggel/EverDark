class_name WorldState extends Node

func _ready() -> void:
	SaveSystem.track("world_state", WorldStateSaver.get_world_state, WorldStateSaver.set_world_state, {"placed_items": { "initial_crafting_table": [3, Vector2(-12.0, 8.0)] }})
