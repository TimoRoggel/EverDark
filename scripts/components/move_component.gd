class_name MoveComponent extends Component

@export var speed: float = 100.0
@export var accelleration: float = 4.0
@export var decelleration: float = 8.0
@export var knockback_resistance: float = 1.0

var dash: DashComponent = null

var desired_movement: Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO

func _enter() -> void:
	dash = controller.get_component(DashComponent)
	controller.should_bounce_conditions.append(func() -> bool: return abs(knockback.length()) > 0.0)

func _update(delta: float) -> void:
	if UIManager.paused:
		return
	var desired_speed: Vector2 = desired_movement * speed
	if abs(knockback.length()) > 0.0:
		if knockback.normalized().dot(desired_speed.normalized()) < 0.5 && abs(knockback.length()) > abs(desired_speed.length()):
			desired_speed = knockback
		else:
			desired_speed = desired_speed + knockback
	var lerp_speed: float = delta
	if desired_movement == Vector2.ZERO:
		lerp_speed *= decelleration
	else:
		lerp_speed *= accelleration
	controller.velocity = controller.velocity.lerp(desired_speed, lerp_speed)

func take_knockback(amount: Vector2, duration: float) -> void:
	knockback = amount * (1.0 / knockback_resistance)
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "knockback", Vector2.ZERO, duration)

func add_force(direction: Vector2) -> void:
	controller.velocity += direction

func _exit() -> void:
	pass
