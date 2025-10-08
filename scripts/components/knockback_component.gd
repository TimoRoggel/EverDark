class_name KnockbackComponent extends Component

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

@export var knockback_duration: float = 0.25
@export var friction: float = 8.0
@export var strength: float = 1200.0

func _enter() -> void:
	pass

func _update(delta: float) -> void:
	if knockback_timer > 0.0:
		knockback_timer -= delta
		if knockback_timer <= 0.0 or knockback.length() < 0.1:
			knockback = Vector2.ZERO
		else:
			knockback = knockback.move_toward(Vector2.ZERO, friction * delta)

func _exit() -> void:
	knockback = Vector2.ZERO

func apply_knockback(force: Vector2, duration: float = -1.0) -> void:
	knockback = force
	knockback_timer = duration if duration > 0 else knockback_duration

func apply_backshots(from_position: Vector2, self_position: Vector2, strength: float = 600.0, duration: float = -1.0) -> void:
	var dir = (self_position - from_position).normalized()
	apply_knockback(dir * strength, duration)
	print("Kachoww2")
