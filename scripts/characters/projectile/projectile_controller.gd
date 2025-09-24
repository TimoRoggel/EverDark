class_name ProjectileController extends CharacterController

@export var projectile: Projectile = null
@export var direction: Vector2 = Vector2.ZERO

var sprite: Sprite2D = null
var shape: CollisionShape2D = null
var timer: Timer = null
var particles: GPUParticles2D = null

var spawner: CharacterController = null
var spawn_speed: Vector2 = Vector2.ZERO
var speed: float = 0.0
var damage_flags: int = 0
var lifetime: float = 0.0

func _init(_projectile: Projectile, _direction: Vector2, _spawner: CharacterController) -> void:
	projectile = _projectile
	direction = _direction
	spawner = _spawner

func _ready() -> void:
	# Sprite
	sprite = Sprite2D.new()
	sprite.texture = projectile.texture
	add_child(sprite)
	# Shape
	shape = CollisionShape2D.new()
	shape.position = projectile.hurtbox.position
	shape.shape = RectangleShape2D.new()
	shape.shape.size = projectile.hurtbox.size
	shape.debug_color = Color(1.0, 0.2, 0.1, 0.4)
	add_child(shape)
	# Timer
	timer = Timer.new()
	add_child(timer)
	timer.timeout.connect(func() -> void: queue_free())
	lifetime = projectile.get_lifetime()
	timer.start(lifetime)
	# Flair
	if projectile.particle_material:
		add_particles()
	# Settings
	z_as_relative = false
	y_sort_enabled = false
	z_index = 100
	collision_layer = 2
	collision_mask = 0
	# Other
	direction = (direction + Vector2(randf_range(-projectile.spread, projectile.spread), randf_range(-projectile.spread, projectile.spread))).normalized()
	#position += direction * 8
	spawn_speed = spawner.get_real_velocity() * 0.1
	spawn_speed += spawner.get_real_velocity() * projectile.inheritance
	speed = projectile.get_speed()
	if projectile.align_rotation:
		rotation = direction.angle()
	super()

func _custom_process(delta: float) -> void:
	var desired_velocity: Vector2 = direction * speed
	desired_velocity += spawn_speed
	desired_velocity.x = abs(desired_velocity.x) * sign(direction.x)
	desired_velocity.y = abs(desired_velocity.y) * sign(direction.y)
	if projectile.velocity_overtime:
		desired_velocity *= projectile.velocity_overtime.sample(lifetime_position())
	velocity = desired_velocity
	if projectile.color_over_time:
		modulate = projectile.color_over_time.gradient.sample((lifetime - timer.time_left) / lifetime)
	if projectile.alpha_over_time:
		modulate.a = projectile.alpha_over_time.curve.sample((lifetime - timer.time_left) / lifetime)
		scale = Vector2(1.0, min(modulate.a * 4.0, 1.0))
		shape.disabled = modulate.a < 0.95
	super(delta)

func add_particles() -> void:
	particles = GPUParticles2D.new()
	particles.process_material = projectile.particle_material
	particles.texture = projectile.particle_texture
	particles.amount = projectile.particle_amount
	particles.amount_ratio = projectile.particle_amount_ratio
	particles.lifetime = projectile.particle_lifetime
	particles.one_shot = projectile.particle_oneshot
	particles.preprocess = projectile.particle_preprocess
	particles.speed_scale = projectile.particle_speed_scale
	particles.explosiveness = projectile.particle_explosiveness
	particles.randomness = projectile.particle_randomness
	particles.local_coords = true
	add_child(particles)

func lifetime_position() -> float:
	return 1.0 - timer.time_left / lifetime

func play_sound(sound: AudioStream) -> void:
	var sound_player: RandomAudioStreamPlayer2D = GameManager.create_audio_player(&"sounds", [sound])
	sound_player.autoplay = true
	sound_player.free_on_completion = true
	sound_player.global_position = global_position
	add_sibling(sound_player)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if projectile.death_projectile:
			play_sound(projectile.death_projectile.shoot_sound)
			for i: int in range(projectile.death_projectile.count):
				var bullet: ProjectileController = ProjectileController.new(projectile.death_projectile, direction, spawner)
				bullet.global_position = global_position
				bullet.damage_flags = damage_flags
				spawner.add_sibling(bullet)
