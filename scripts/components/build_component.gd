class_name BuildComponent extends Component

const MIN_DISTANCE: float = 40.0
const PREVIEW_OFFSET: Vector2 = Vector2(0.0, -8.0)
const LUMIN_PARTICLES: PackedScene = preload("uid://hr08sa6g5b4v")

@export var hotbar_container : HBoxContainer

const PLACEABLE_SCENES: Dictionary = {
	3: preload("res://scenes/crafting/crafting.tscn"),
	4: preload("res://Chest/chest.tscn"),
	26: preload("uid://7cxdqearioco")
}
const PREVIEWABLE_ITEMS: Array[int] = [3,4,24,25,26]

var input: InputComponent = null
var inventory: InventoryComponent = null
var current_positions: PackedVector2Array = []
var current_lumin_positions: PackedVector2Array = []
var lumin_player: RandomAudioStreamPlayer2D = null
var build_preview: Sprite2D = null

static func place_item(item: int, pos: Vector2) -> void:
	var scene: Node2D = PLACEABLE_SCENES[item].instantiate()
	Engine.get_main_loop().current_scene.add_child.call_deferred(scene)
	scene.global_position = pos
	WorldStateSaver.placed_items[scene.name] = [item, pos]
	scene.scale = Vector2.ONE * 0.1
	var tween: Tween = scene.create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(scene, "scale", Vector2.ONE, 0.5)
	tween.play()
	await tween.finished

func _enter() -> void:
	input = controller.get_component(InputComponent)
	inventory = controller.get_component(InventoryComponent)
	input.place.connect(place)
	lumin_player = GameManager.create_audio_player(&"SFX", [preload("uid://dr6sn17qunu")], self)
	build_preview = Sprite2D.new()
	build_preview.modulate.a = 0.75
	build_preview.visible = false
	build_preview.z_as_relative = false
	build_preview.z_index = 999
	add_child(build_preview)

func _update(_delta: float) -> void:
	if build_preview.visible:
		build_preview.visible = false
	var held_slot_item: int = inventory.held_item
	if held_slot_item < 0:
		return
	if !inventory.has(held_slot_item):
		return
	if !PREVIEWABLE_ITEMS.has(held_slot_item):
		return
	build_preview.global_position = get_global_mouse_position() + PREVIEW_OFFSET
	build_preview.texture = DataManager.get_resource_by_id("items", held_slot_item).icon
	build_preview.visible = true

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
	BuildComponent.place_item(held_slot_item, at)
	current_positions.append(at)
	inventory.remove(held_slot_item)
	hotbar_container.select_slot(hotbar_container.currently_selected_slot)

func place_other(at: Vector2, held_slot_item: int) -> void:
	match held_slot_item:
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
	var particles: GPUParticles2D = LUMIN_PARTICLES.instantiate()
	particles.global_position = at
	get_tree().current_scene.add_child(particles)
	particles.emitting = true
	GameManager.finish_objective(5)
	lumin_player.global_position = at
	lumin_player.play_randomized()
	Generator.lumin_positions.append(at)
	Generator.lumin_sizes.append(0.0)
	grow_lumin(Generator.lumin_sizes.size() - 1, size)
	current_lumin_positions.append(at)
	inventory.remove(held_slot_item)
	await particles.finished
	if particles:
		particles.queue_free()

func grow_lumin(index: int, target_size: float) -> void:
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SPRING)
	tween.tween_method(Generator.set_lumin_size.bind(index), 0.0, target_size, 0.25)
	tween.play()
