class_name WorldState extends Node

const OPENING_CUTSCENE = preload("uid://nviqebyfck7g")

func _ready() -> void:
	SaveSystem.track("world_state", WorldStateSaver.get_world_state, WorldStateSaver.set_world_state, {"placed_items": { "initial_crafting_table": [3, Vector2(-12.0, 8.0)] }, "new_save": true})
	await get_tree().physics_frame
	await get_tree().physics_frame
	await get_tree().physics_frame
	if WorldStateSaver.new_save:
		CutsceneManager.play(OPENING_CUTSCENE)
	WorldStateSaver.new_save = false
