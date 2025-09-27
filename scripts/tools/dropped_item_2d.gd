@tool
class_name DroppedItem2D extends Interactable2D

const ITEM_PICKUP_RUNNABLE: GDScript = preload("uid://jxi2b1l6t8j3")

@export var item: Item = null
@export var amount: int = 1

var timeout_timer: Timer = Timer.new()

func _ready() -> void:
	z_as_relative = false
	y_sort_enabled = true
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = item.icon
	add_child(sprite)
	timeout_timer.one_shot = true
	add_child(timeout_timer)
	interact_script = ITEM_PICKUP_RUNNABLE
	active = true
	custom_parameter = str("{\"item\": ", item.id, ", \"quantity\": ", amount, "}")
	super()

func timeout(count: float = 2.0) -> void:
	active = false
	timeout_timer.start(count)
	await timeout_timer.timeout
	active = true
