class_name DashComponent extends Component

@export var dash_trail_scene: PackedScene = null
@export var dash_sounds: Array[AudioStream] = []

var health: HealthComponent = null
var movement: MoveComponent = null

var audio_player: RandomAudioStreamPlayer2D = null
var dashing: bool = false
var dash_timer: Timer = null
var dash_trail_particles: GPUParticles2D = null
var is_dashing: bool = false
var default_dash: Vector2 = Vector2.ZERO

func _enter() -> void:
	controller.should_bounce_conditions.append(func() -> bool: return is_dashing)
	health = controller.get_component(HealthComponent)
	movement = controller.get_component(MoveComponent)
	audio_player = GameManager.create_audio_player(&"sounds", dash_sounds)
	add_child(audio_player)
	dash_timer = Timer.new()
	dash_timer.wait_time = 0.5
	dash_timer.one_shot = true
	dash_timer.timeout.connect(on_dash_timer_timeout)
	add_child(dash_timer)
	if dash_trail_scene:
		dash_trail_particles = dash_trail_scene.instantiate()
		add_child(dash_trail_particles)
		dash_trail_particles.emitting = false

func _update(_delta: float) -> void:
	if dashing && can_dash():
		dash()

func _exit() -> void:
	pass

func can_dash() -> bool:
	return dash_timer.is_stopped() && movement && !(dash_trail_particles && dash_trail_particles.emitting)

func dash() -> void:
	if !can_dash():
		return
	is_dashing = true
	audio_player.play_randomized()
	if dash_trail_particles:
		dash_trail_particles.emitting = true
	dash_timer.start()
	var dash_direction: Vector2 = movement.desired_movement
	if dash_direction == Vector2.ZERO:
		dash_direction = default_dash * 2.0
	controller.velocity += dash_direction * 480.0
	if health:
		health.invulnerable = true
		await get_tree().create_timer(0.25).timeout
		health.invulnerable = false
		if dash_trail_particles:
			await get_tree().create_timer(0.25).timeout
			dash_trail_particles.emitting = false
	is_dashing = false

func on_dash_timer_timeout() -> void:
	pass
