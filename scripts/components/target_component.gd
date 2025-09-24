@tool
class_name TargetComponent extends Component

@export var radius: float = 16.0
var targeting_flags: int = 0:
	set(value):
		targeting_flags = value
		notify_property_list_changed()

var target: CharacterController = null:
	set(value):
		target = value
		target_changed.emit()
var valid_targets: Array[CharacterController] = []

var area: Area2D = null
var shape: CollisionShape2D = null

signal target_changed

func _get_property_list():
	return CharacterController.get_flag_properties("targeting_flags")

func _enter() -> void:
	area = Area2D.new()
	add_child(area)
	area.body_entered.connect(on_body_entered)
	area.body_exited.connect(on_body_exited)
	shape = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = radius
	area.add_child(shape)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

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
