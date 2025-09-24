class_name AlignTargetComponent extends Component

## The node that is modified based on the target
@export var aligned_node: Node2D = null
## How much the [member aligned_node] is affected by the target (1 = on top of the target)
@export_range(0.0, 1.0, 0.01) var alignment_weight: float = 0.5
## Added after realignment
@export var offset: Vector2 = Vector2.ZERO
## How much the [member aligned_node] is offset towards the target
@export var aligned_offset: float = 0.0
## How much the target is offset towards the [member aligned_node]
@export var target_offset: float = 0.0

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	if !controller.get_target():
		return
	var start: Vector2 = controller.global_position
	var end: Vector2 = controller.get_target().global_position
	start += get_point(start, end) * aligned_offset
	end += get_point(end, start) * target_offset
	aligned_node.global_position = lerp(start, end, alignment_weight) + offset

func _exit() -> void:
	pass

func get_point(from: Vector2, to: Vector2) -> Vector2:
	return Vector2.from_angle(from.angle_to_point(to))
