@tool
class_name DroppedItem2D extends Interactable2D

const ITEM_PICKUP_RUNNABLE: GDScript = preload("uid://jxi2b1l6t8j3")
const MERGE_DISTANCE: float = 16.0

@export var item: Item = null:
	set(value):
		item = value
		update_param()

@export var amount: int = 1:
	set(value):
		amount = value
		update_param()

@export var dropped_by_player: bool = false

@export var float_hieght: float = 5.0
@export var float_speed: float = 2.0
var timeout_timer: Timer = Timer.new()
var merge_area: Area2D = Area2D.new()
var sprite: Sprite2D = Sprite2D.new()
var base_y: float
var time: float = 0.0

static func drop(item_id: int, count: int, pos: Vector2, play_sound: bool = true, _dropped_by_player: bool = false) -> void:
	var dropped_item: DroppedItem2D = DroppedItem2D.new()
	dropped_item.item = DataManager.get_resource_by_id("items", item_id)
	dropped_item.amount = count
	dropped_item.dropped_by_player = _dropped_by_player

	Engine.get_main_loop().current_scene.add_child(dropped_item)
	dropped_item.global_position = pos
	dropped_item.scale_to(1.0)

	if play_sound:
		dropped_item.timeout(0.75)
		var dropped_sound: RandomAudioStreamPlayer2D = GameManager.create_audio_player(&"SFX", [preload("uid://dwfwgrm6ia01k")], dropped_item)
		dropped_sound.play_randomized()
		await dropped_sound.finished
		dropped_sound.queue_free()

	WorldStateSaver.dropped_items[dropped_item.name] = [item_id, count, pos, _dropped_by_player]

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		WorldStateSaver.dropped_items.erase(name)

func _ready() -> void:
	z_as_relative = false
	y_sort_enabled = true
	z_index = 200
	sprite.texture = item.icon
	sprite.use_parent_material = true
	add_child(sprite)
	base_y = sprite.position.y
	timeout_timer.one_shot = true
	add_child(timeout_timer)
	interact_script = ITEM_PICKUP_RUNNABLE
	active = true
	super()
	merge_area.collision_layer = 0
	merge_area.collision_mask = 4
	merge_area.monitorable = false
	add_child(merge_area)
	var merge_shape: CollisionShape2D = CollisionShape2D.new()
	merge_shape.debug_color = Color(0.444, 0.91, 0.328, 0.502)
	merge_shape.shape = CircleShape2D.new()
	merge_shape.shape.radius = MERGE_DISTANCE
	merge_area.add_child(merge_shape)

func _process(delta: float) -> void:
	time += delta * float_speed
	sprite.position.y = base_y + sin(time) * float_hieght

func _physics_process(_delta: float) -> void:
	if !active:
		return

	var nearby_items: Array = merge_area.get_overlapping_areas().filter(
		func(n: Area2D) -> bool:
			return n != self && is_instance_of(n, DroppedItem2D) && n.item.id == item.id && n.amount + amount <= item.stack_size
			)
	if nearby_items.is_empty():
		return
	for d: DroppedItem2D in nearby_items:
		d.active = false
	if !active:
		return
	var positions: PackedVector2Array = nearby_items.map(func(n: DroppedItem2D) -> Vector2: return n.global_position)
	positions.append(global_position)
	global_position = VectorHelper.avg(positions)
	for d: DroppedItem2D in nearby_items:
		amount += d.amount
		d.queue_free()

func scale_to(size: float) -> void:
	scale = Vector2.ONE * (1.0 - size)
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(self, "scale", Vector2.ONE * size, 0.25)
	tween.play()
	await tween.finished

func update_param() -> void:
	custom_parameter = str("{\"item\": ", item.id, ", \"quantity\": ", amount, "}")
	sprite.texture = item.icon

func timeout(count: float = 0.25) -> void:
	active = false
	timeout_timer.start(count)
	await timeout_timer.timeout
	active = true
