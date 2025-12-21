@tool
class_name TargetComponent extends Component

@export var radius: float = 16.0
var targeting_flags: int = 0:
	set(value):
		targeting_flags = value
		notify_property_list_changed()
		queue_redraw()

var target: CharacterController = null:
	set(value):
		target = value
		target_changed.emit()
var valid_targets: Array[CharacterController] = []

var area: Area2D = null
var shape: CollisionShape2D = null
var agent: NavigationAgent2D = NavigationAgent2D.new()
var obstacle: NavigationObstacle2D = NavigationObstacle2D.new()

signal target_changed

func _get_property_list() -> Array[Dictionary]:
	return CharacterController.get_flag_properties("targeting_flags")

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, radius, Color(0.305, 0.87, 0.646, 0.502))

func _enter() -> void:
	if Engine.is_editor_hint():
		return
	area = Area2D.new()
	add_child(area)
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = radius
	area.add_child(shape)
	agent.avoidance_enabled = true
	agent.neighbor_distance = 120.0
	agent.radius = 16.0
	agent.max_neighbors = 5
	add_child(agent)
	obstacle.radius = 12.0
	add_child(obstacle)

func _update(_delta: float) -> void:
	if !target:
		return
	agent.target_position = target.global_position

func _exit() -> void:
	pass

func get_target_direction() -> Vector2:
	if agent.is_target_reached():
		return Vector2.ZERO
	return global_position.direction_to(agent.get_next_path_position())

func on_body_entered(body: Node) -> void:
	if body == controller:
		return
	if !is_instance_of(body, CharacterController):
		return
	if !valid_targets.has(body):
		if (body.flags & targeting_flags) == targeting_flags:
			valid_targets.append(body)
	if !target:
		find_new_target()

func on_body_exited(body: Node) -> void:
	if body == controller:
		return
	if !is_instance_of(body, CharacterController):
		return
	valid_targets.erase(body)
	if body == target:
		clear_target()

func find_new_target() -> void:
	if !area.has_overlapping_bodies():
		return
	if valid_targets.size() < 1:
		return
	valid_targets.sort_custom(func(a: Node2D, b: Node2D) -> bool: return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position))
	target = valid_targets[0]

func try_add_target(new_target: CharacterController) -> void:
	if target:
		return
	if (new_target.flags & targeting_flags) != targeting_flags:
		return
	target = new_target

func clear_target() -> void:
	target = null
