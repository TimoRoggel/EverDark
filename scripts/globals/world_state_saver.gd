extends Node

var dropped_items: Dictionary = {}
var placed_items: Dictionary = { "new_save": true, "initial_crafting_table": [3, Vector2(-12.0, 8.0)] }
var destroyed_items: PackedStringArray = []
var chest_contents: Dictionary = {}
var new_save: bool = true

func get_world_state() -> Dictionary:
	return {
		"new_save": new_save,
		"dropped_items": dropped_items,
		"placed_items": placed_items,
		"destroyed_items": ArrayHelper.make_unique(destroyed_items),
		"chest_contents": chest_contents
	}

func set_world_state(state: Dictionary) -> void:
	if state.is_empty():
		return
	new_save = state.get("new_save", true)
	dropped_items = state.get("dropped_items", {})
	placed_items = state.get("placed_items", {})
	destroyed_items = state.get("destroyed_items", [])
	chest_contents = state.get("chest_contents", {})
	drop_items()
	place_items()
	destroy_items()

func drop_items() -> void:
	var copy: Dictionary = dropped_items.duplicate()
	dropped_items.clear()
	for item: Array in copy.values():
		DroppedItem2D.drop(item[0], item[1], item[2], false)

func place_items() -> void:
	var copy: Dictionary = placed_items.duplicate()
	placed_items.clear()
	for item: Array in copy.values():
		BuildComponent.place_item(item[0], item[1])

func destroy_items() -> void:
	for item_name: String in destroyed_items:
		var possible_nodes: Array[Node] = get_tree().current_scene.find_children(item_name)
		if possible_nodes.size() <= 0:
			continue
		var node: Node = possible_nodes[0]
		for n: Node in possible_nodes:
			if n.name == item_name:
				node = n
				break
		if !node:
			continue
		node.queue_free()
