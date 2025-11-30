class_name BuildComponent extends Component

const MIN_DISTANCE: float = 40.0

@export var hotbar_container : HBoxContainer

const placeable_scenes: Dictionary = {
	3: preload("res://scenes/crafting/crafting.tscn"),
	4: preload("res://Chest/chest.tscn")
}

var input: InputComponent = null
var inventory: InventoryComponent = null
var current_positions: PackedVector2Array = []
var current_lumin_positions: PackedVector2Array = []
var lumin_player: RandomAudioStreamPlayer2D = null

func _enter() -> void:
	input = controller.get_component(InputComponent)
	inventory = controller.get_component(InventoryComponent)
	input.place.connect(place)
	lumin_player = GameManager.create_audio_player(&"SFX", [preload("uid://dr6sn17qunu")], self)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func place(at: Vector2) -> void:
	var held_slot_item: int = inventory.held_item
	if held_slot_item < 0:
		return
	if !inventory.has(held_slot_item):
		return
	if inventory.is_placeable(held_slot_item):
		place_scene(at, held_slot_item)
	else:
		place_other(at, held_slot_item)

func place_scene(at: Vector2, held_slot_item: int) -> void:
	for coords in current_positions:
		if coords.distance_to(at) < 1.0:
			return
	var scene = placeable_scenes[held_slot_item].instantiate()
	get_tree().current_scene.add_child(scene)
	scene.global_position = at
	current_positions.append(at)
	inventory.remove(held_slot_item)
	hotbar_container.select_slot(hotbar_container.currently_selected_slot)

func place_other(at: Vector2, held_slot_item: int) -> void:
	match held_slot_item:
		0:
			use_lumin(at, held_slot_item, Generator.LUMIN_SIZE)
		25:
			use_lumin(at, held_slot_item, Generator.LUMIN_TORCH_SIZE)
		24:
			use_lumin(at, held_slot_item, Generator.LUMIN_LANTERN_SIZE)

func refresh_held_item() -> void:
	hotbar_container.select_slot(hotbar_container.currently_selected_slot)

func use_lumin(at: Vector2, held_slot_item: int, size: float) -> void:
	if !Generator.is_in_everdark(at):
		return
	for coords: Vector2 in current_lumin_positions:
		if coords.distance_squared_to(at) < MIN_DISTANCE:
			return
	lumin_player.global_position = at
	lumin_player.play_randomized()
	Generator.lumin_positions.append(at)
	Generator.lumin_sizes.append(size)
	current_lumin_positions.append(at)
	inventory.remove(held_slot_item)
