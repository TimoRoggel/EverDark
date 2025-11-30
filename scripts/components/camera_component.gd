class_name CameraComponent extends Component

const DISTANCE_THRESHOLD: float = 128.0

@export var camera: Camera2D = null

var base_offset: Vector2 = Vector2.ZERO
var current_shake: CameraTween = null

func _init() -> void:
	updates_in_physics = false

func _enter() -> void:
	base_offset = camera.offset
	GameManager.main_camera_component = self

func _update(delta: float) -> void:
	camera.global_position = camera.global_position.lerp(get_camera_position(), delta * 25.0)

func _exit() -> void:
	pass

func get_camera_position() -> Vector2:
	var current: Vector2 = controller.global_position
	var target: Vector2 = get_global_mouse_position()
	var distance: float = current.distance_to(target)
	if distance > DISTANCE_THRESHOLD:
		target = current + current.direction_to(target) * DISTANCE_THRESHOLD
	var weight: float = clampf(distance * 0.1, 0, 0.25)
	var desired_position: Vector2 = lerp(current, target, weight)
	return desired_position

func shake(amount: float, duration: float = 0.1, addative: bool = false) -> void:
	if current_shake != null:
		if addative:
			amount += current_shake.amount
		else:
			amount = max(amount, current_shake.amount)
		duration += current_shake.remaining_time()
		current_shake.end()
		current_shake = null
	amount = min(amount, 24.0)
	duration = min(amount, 0.15)
	var tween: Tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE)
	var shake_tween: CameraTween = CameraTween.new(tween, amount, duration)
	current_shake = shake_tween
	tween.tween_property(camera, "offset", Vector2(randf_range(-amount, amount), randf_range(-amount, amount)), duration * 0.5)
	tween.tween_property(camera, "offset", Vector2.ZERO, duration * 0.5)
	await tween.finished
	if current_shake == shake_tween:
		current_shake = null
