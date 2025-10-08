class_name MoveComponent extends Component

@export var speed: float = 150.0
@export var acceleration: float = 15.0
@export var deceleration: float = 20.0

var desired_movement: Vector2 = Vector2.ZERO
var dash: DashComponent = null

func _enter() -> void:
	dash = controller.get_component(DashComponent)

func _update(delta: float) -> void:
	var kb: KnockbackComponent = controller.get_component(KnockbackComponent)
	var input_velocity: Vector2 = desired_movement * speed

	if kb and kb.knockback.length() > 0.1:
		controller.velocity = kb.knockback
	else:
		var lerp_speed: float = delta
		if desired_movement == Vector2.ZERO:
			lerp_speed *= deceleration
		else:
			lerp_speed *= acceleration
		controller.velocity = controller.velocity.lerp(input_velocity, lerp_speed)

func _exit() -> void:
	controller.velocity = Vector2.ZERO
