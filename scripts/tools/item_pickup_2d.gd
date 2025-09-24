class_name ItemPickup2D extends Area2D

@export var item: Item = null
@export var amount: int = 1

var timeout_timer: Timer = Timer.new()

func _ready() -> void:
	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2i.ONE * 16
	add_child(shape)
	z_as_relative = false
	y_sort_enabled = true
	var sprite: Sprite2D = Sprite2D.new()
	sprite.texture = item.icon
	add_child(sprite)
	timeout_timer.one_shot = true
	add_child(timeout_timer)

func timeout(count: float = 2.0) -> void:
	timeout_timer.start(count)

func can_pickup() -> bool:
	return timeout_timer.time_left <= 0.0
