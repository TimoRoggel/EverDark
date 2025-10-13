class_name KnockbackComponent extends Component

@export var knockback_resistance: float = 1.0

var knockback_velocity: Vector2 = Vector2.ZERO
var is_being_knocked_back: bool = false

func _enter() -> void:
	controller.should_bounce_conditions.append(func() -> bool: return is_being_knocked_back)

func _update(delta: float) -> void:
	if is_being_knocked_back:
		controller.velocity += knockback_velocity
		knockback_velocity = knockback_velocity.lerp(Vector2.ZERO, delta * 8.0)
		
		if knockback_velocity.length_squared() < 1.0:
			is_being_knocked_back = false
			knockback_velocity = Vector2.ZERO
	
	queue_redraw()

func _exit() -> void:
	pass

func apply_knockback(direction: Vector2, force: float, duration: float = 0.1) -> void:
	var effective_force: float = force * 300.0
	knockback_velocity = direction.normalized() * effective_force * (1.0 / knockback_resistance)
	is_being_knocked_back = true
	
	get_tree().create_timer(duration).timeout.connect(func(): 
		is_being_knocked_back = false
		knockback_velocity = Vector2.ZERO
		print("KAchoww")
	)

func _draw() -> void:
	if Engine.is_editor_hint() || !is_being_knocked_back:
		return
	
	var line_length: float = knockback_velocity.length() * 0.1
	if line_length > 0:
		var direction: Vector2 = knockback_velocity.normalized()
		var end_point: Vector2 = direction * line_length
		draw_line(Vector2.ZERO, end_point, Color.RED, 2.0)
		draw_circle(end_point, 3.0, Color.RED)
