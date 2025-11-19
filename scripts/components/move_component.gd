class_name MoveComponent extends Component

@export var speed: float = 100.0
@export var accelleration: float = 40.0
@export var decelleration: float = 80.0
@export var knockback_resistance: float = 1.0
@export_group("Sounds")
@export var step_sounds: Array[AudioStream] = []
@export var step_cooldown: float = 0.1

var dash: DashComponent = null

var desired_movement: Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO
var step_player: RandomAudioStreamPlayer2D = null
var step_timestamp: float = 0.0

func _enter() -> void:
	dash = controller.get_component(DashComponent)
	controller.should_bounce_conditions.append(func() -> bool: return abs(knockback.length()) > 0.0)
	step_player = GameManager.create_audio_player(&"SFX", step_sounds, self)

func _update(delta: float) -> void:
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
	step(delta)

func take_knockback(amount: Vector2, duration: float) -> void:
	knockback = amount * (1.0 / knockback_resistance)
	var tween: Tween = get_tree().create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.tween_property(self, "knockback", Vector2.ZERO, duration)

func add_force(direction: Vector2) -> void:
	controller.velocity += direction

func step(delta: float) -> void:
	if !step_player:
		return
	if step_player.playing:
		return
	if controller.velocity.length() <= 4.0:
		return
	if step_timestamp <= step_cooldown:
		step_timestamp += delta
		return
	step_player.play_randomized()
	step_timestamp = 0.0

func _exit() -> void:
	pass
