class_name HealthComponent extends Component

#const HEALTHBAR_F: CompressedTexture2D = preload("res://graphics/ui/healthbar_f.png")
#const HEALTHBAR_U: CompressedTexture2D = preload("res://graphics/ui/healthbar_u.png")
#const HEALTHBAR_D: CompressedTexture2D = preload("res://graphics/ui/healthbar_d.png")

@export var max_health: float = 10.0
@export var hit_sounds: Array[AudioStream] = []
@export var death_sounds: Array[AudioStream] = []
@export var persistent: bool = false

var healthbar: TextureProgressBar = null
var healthbar_delta: TextureProgressBar = null
var area: Area2D = null
var shape: CollisionShape2D = null

var current_health: float = max_health
var invulnerabilities: Dictionary[Projectile, float] = {}
var invulnerable: bool = false
var alive: bool = true
var hit_player: RandomAudioStreamPlayer2D = null
var death_player: RandomAudioStreamPlayer2D = null
var healthbar_delta_timer: Timer = null
var screen_shake_amount: float = 0.5

signal damage_taken(from: ProjectileController)

func _enter() -> void:
	# Healthbar
	healthbar = TextureProgressBar.new()
	healthbar.z_as_relative = false
	healthbar.z_index = 200
	healthbar.size = Vector2(16, 4)
	healthbar.position = Vector2(-8, -16)
	#healthbar.texture_progress = HEALTHBAR_F
	healthbar_delta = TextureProgressBar.new()
	healthbar_delta.z_as_relative = false
	healthbar_delta.z_index = 199
	healthbar_delta.size = Vector2(16, 4)
	healthbar_delta.position = Vector2(-8, -16)
	#healthbar_delta.texture_under = HEALTHBAR_U
	#healthbar_delta.texture_progress = HEALTHBAR_D
	healthbar_delta_timer = Timer.new()
	add_child(healthbar_delta_timer)
	healthbar_delta_timer.timeout.connect(func() -> void:
		var tween: Tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
		tween.tween_property(healthbar_delta, "value", healthbar.value, 0.25)
	)
	update_healthbar()
	healthbar_delta.value = healthbar.value
	if !persistent:
		healthbar.visible = false
		healthbar_delta.visible = false
	add_child(healthbar)
	add_child(healthbar_delta)
	# Hit Detection
	area = Area2D.new()
	area.collision_mask = 2
	add_child(area)
	area.body_entered.connect(on_hit_detected)
	shape = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = Vector2.ONE * 8
	area.add_child(shape)
	# Audio
	if hit_sounds.size() > 0:
		hit_player = GameManager.create_audio_player(&"sounds", hit_sounds)
		add_child(hit_player)
	if death_sounds.size() > 0:
		death_player = GameManager.create_audio_player(&"sounds", death_sounds)
		add_child(death_player)

func _update(delta: float) -> void:
	if current_health <= 0:
		death()
	var new_invulnerabilities: Dictionary[Projectile, float] = {}
	for key: Projectile in invulnerabilities.keys():
		var new_time: float = invulnerabilities[key] - delta
		if new_time > 0.0:
			new_invulnerabilities[key] = new_time
	invulnerabilities = new_invulnerabilities

func _exit() -> void:
	pass

func update_healthbar() -> void:
	healthbar.value = current_health / max_health * 100.0
	healthbar.visible = true
	healthbar_delta.visible = true
	healthbar_delta_timer.start(0.25)

func death() -> void:
	if is_queued_for_deletion():
		return
	if !alive:
		return
	alive = false
	ScoreManager.spawn_score_particle(randi_range(85, 115), global_position)
	controller.visible = false
	if death_player:
		death_player.play_randomized()
		await death_player.finished
	controller.process_mode = Node.PROCESS_MODE_DISABLED
	controller.queue_free()

func can_get_damaged(projectile: ProjectileController) -> bool:
	return (controller.flags & projectile.damage_flags) == controller.flags

func take_damage(projectile: ProjectileController) -> void:
	if !can_get_damaged(projectile):
		return
	var proj: Projectile = projectile.projectile
	if invulnerabilities.has(proj):
		if invulnerabilities[proj] > 0.0:
			return
	damage_taken.emit(projectile)
	current_health -= proj.power
	GameManager.camera_shake(screen_shake_amount * proj.power * 8.0 * proj.shake_amount, proj.shake_duration, proj.shake_addative)
	if current_health <= 0:
		return
	if hit_player:
		hit_player.play_randomized()
	calc_knockback(projectile)
	update_healthbar()
	var invulnerability: float = proj.invulnerability
	invulnerabilities[proj] = invulnerability
	controller.set_damaged(true)
	GameManager.slowdown(proj.slowdown, proj.slowdown_duration_ms)
	await get_tree().create_timer(max(invulnerability, 0.15)).timeout
	controller.set_damaged(false)
	if !controller || is_queued_for_deletion():
		return
	await get_tree().create_timer(2.0).timeout
	if !projectile || is_queued_for_deletion():
		return

func calc_knockback(projectile: ProjectileController) -> void:
	if projectile.projectile.knockback == 0.0:
		return
	if !"movement" in controller:
		return
	controller.movement.take_knockback(projectile.get_real_velocity() * projectile.projectile.knockback, projectile.projectile.knockback * 0.1)

func on_hit_detected(body: Node) -> void:
	if invulnerable:
		return
	if is_instance_of(body, ProjectileController):
		if invulnerabilities.has(body.projectile):
			if invulnerabilities[body.projectile] > 0.0:
				return
		if body.spawner != controller || body.projectile.can_hit_owner:
			take_damage(body as ProjectileController)
