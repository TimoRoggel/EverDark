class_name BuildComponent extends Component

const placeable_scenes: Dictionary = {
	3: preload("res://scenes/crafting/crafting.tscn"),
	4: preload("res://Chest/chest.tscn")
}

var input: InputComponent = null
var inventory: InventoryComponent = null
var current_positions: PackedVector2Array = []

func _enter() -> void:
	input = controller.get_component(InputComponent)
	inventory = controller.get_component(InventoryComponent)
	input.place.connect(place)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func place(at: Vector2) -> void:
	var held_slot_item = inventory.container.get_slots()[inventory.held_slot].inventory_item
	if not held_slot_item:
		return
	if not inventory.is_placeable(held_slot_item):
		return
	for coords in current_positions:
		if coords.distance_to(at) < 1.0:
			return
	var scene = placeable_scenes[held_slot_item.item.id].instantiate()
	get_tree().current_scene.add_child(scene)
	scene.global_position = at
	current_positions.append(at)
	inventory.remove(held_slot_item.item.id)
