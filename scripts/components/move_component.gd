class_name MoveComponent extends Component

@export var default_speed: float = 100.0
@export var sprint_speed: float = 160.0
@export var accelleration: float = 4.0
@export var decelleration: float = 8.0
@export var knockback_resistance: float = 1.0
@export_group("Sounds")
@export var step_sounds: Array[AudioStream] = []
@export var step_cooldown: float = 0.1
@export var sprint_time: float = 5.0
@export var sprint_cooldown: float = 3.0

var speed : float

var sprinting : bool = false
var sprint_timer : Timer = null
var is_in_cooldown : bool = false

var dash: DashComponent = null

var desired_movement: Vector2 = Vector2.ZERO
var knockback: Vector2 = Vector2.ZERO
var step_player: RandomAudioStreamPlayer2D = null
var step_timestamp: float = 0.0
var inputs : InputComponent = null
var animation_player: AnimatedSprite2D = null
var animation_scale: float = 1.0
var sprint_scale: float = 1.0

func _enter() -> void:
	speed = default_speed
	dash = controller.get_component(DashComponent)
	controller.should_bounce_conditions.append(func() -> bool: return abs(knockback.length()) > 0.0)
	step_player = GameManager.create_audio_player(&"SFX", step_sounds, self)
	await get_tree().create_timer(1.0).timeout
	if controller is PlayerController:
		if controller.get_component(AnimationComponent):
			animation_player = controller.get_component(AnimationComponent).animated_sprite
		sprint_scale = default_speed/100*sprint_speed/100
		if controller.get_component(InputComponent):
			inputs = controller.get_component(InputComponent)
			inputs.sprint.connect(sprint)
			inputs.walk.connect(walk)

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
	
func sprint():
	if not sprinting and not sprint_timer:
		start_sprint_timer()
		animation_player.speed_scale = animation_scale
	if not is_in_cooldown:
		sprinting = true
		speed = sprint_speed
		animation_player.speed_scale = sprint_scale
	
func walk():
	sprinting = false
	stop_sprint_timer()
	speed = default_speed
	animation_player.speed_scale = animation_scale
	
func start_sprint_timer():
	sprint_timer = Timer.new()
	sprint_timer.wait_time = sprint_time
	sprint_timer.one_shot = true
	sprint_timer.timeout.connect(cooldown)
	add_child(sprint_timer)
	sprint_timer.start()
	
func cooldown():
	walk()
	is_in_cooldown = true
	await get_tree().create_timer(sprint_cooldown).timeout
	is_in_cooldown = false
	
func stop_sprint_timer():
	sprint_timer.stop()
	sprint_timer.queue_free()

func _exit() -> void:
	pass
