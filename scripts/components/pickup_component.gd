@tool
class_name PickupComponent extends Component

const DEBUG_COLOR: Color = Color(1.0, 0.805, 0.27, 0.502)

@export var pickup_radius: float = 16.0:
	set(value):
		pickup_radius = value
		queue_redraw()
@export var pickup_distance: float = 8.0:
	set(value):
		pickup_distance = value
		queue_redraw()

var area: Area2D = Area2D.new()
var shape: CollisionShape2D = CollisionShape2D.new()
var inventory: InventoryComponent = null

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, pickup_radius, DEBUG_COLOR)
		draw_circle(Vector2.ZERO, pickup_radius, DEBUG_COLOR, false)
		draw_circle(Vector2.ZERO, pickup_distance, DEBUG_COLOR)
		draw_circle(Vector2.ZERO, pickup_distance, DEBUG_COLOR, false)

func _enter() -> void:
	if Engine.is_editor_hint():
		return
	inventory = controller.get_component(InventoryComponent)
	add_child(area)
	shape.shape = CircleShape2D.new()
	shape.shape.radius = pickup_radius
	area.add_child(shape)

func _update(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	for body: Node2D in area.get_overlapping_areas():
		if !is_instance_of(body, ItemPickup2D):
			continue
		if !body.can_pickup():
			continue
		var d: float = body.global_position.distance_to(global_position)
		if d <= pickup_distance:
			if inventory.add_item(body.item, body.amount) == 0:
				body.queue_free()
			else:
				body.timeout()
		body.global_position = body.global_position.move_toward(global_position, delta * 160.0)

func _exit() -> void:
	pass
