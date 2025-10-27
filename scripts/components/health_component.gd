class_name HealthComponent extends Component

#const HEALTHBAR_F: CompressedTexture2D = preload("res://graphics/ui/healthbar_f.png")
#const HEALTHBAR_U: CompressedTexture2D = preload("res://graphics/ui/healthbar_u.png")
#const HEALTHBAR_D: CompressedTexture2D = preload("res://graphics/ui/healthbar_d.png")

@export var max_health: float = 10.0
@export var hit_sounds: Array[AudioStream] = []
@export var death_sounds: Array[AudioStream] = []
@export var persistent: bool = false
@export var death_drops: PackedInt32Array = []

var healthbar: TextureProgressBar = null
var healthbar_delta: TextureProgressBar = null
var current_health: float = max_health
var alive: bool = true
var hit_player: RandomAudioStreamPlayer2D = null
var death_player: RandomAudioStreamPlayer2D = null
var healthbar_delta_timer: Timer = null
var screen_shake_amount: float = 0.5

signal damage_taken(from: AttackController)

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
	# Audio
	if hit_sounds.size() > 0:
		hit_player = GameManager.create_audio_player(&"sounds", hit_sounds)
		add_child(hit_player)
	if death_sounds.size() > 0:
		death_player = GameManager.create_audio_player(&"sounds", death_sounds)
		add_child(death_player)

func _update(_delta: float) -> void:
	if current_health <= 0:
		death()

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
	controller.visible = false
	if death_player:
		death_player.play_randomized()
		await death_player.finished
	controller.process_mode = Node.PROCESS_MODE_DISABLED
	controller.queue_free()
	for item_id: int in death_drops:
		DroppedItem2D.drop(item_id, 1, global_position)

func can_get_damaged(attack: AttackController) -> bool:
	return (controller.flags & attack.damage_flags) == controller.flags

func take_damage(attack: AttackController) -> void:
	if !can_get_damaged(attack):
		return
	var proj: Attack = attack.attack
	damage_taken.emit(attack)
	current_health -= proj.power
	GameManager.camera_shake(screen_shake_amount * proj.power * 8.0 * proj.shake_amount, proj.shake_duration, proj.shake_addative)
	if current_health <= 0:
		return
	if hit_player:
		hit_player.play_randomized()
	calc_knockback(attack)
	update_healthbar()
	var invulnerability: float = proj.invulnerability
	controller.set_damaged(true)
	GameManager.slowdown(proj.slowdown, proj.slowdown_duration_ms)
	await get_tree().create_timer(max(invulnerability, 0.15)).timeout
	controller.set_damaged(false)
	if !controller || is_queued_for_deletion():
		return
	await get_tree().create_timer(2.0).timeout
	if !attack || is_queued_for_deletion():
		return
		
func apply_environmental_damage(env: EverdarkDamageComponent) -> void:
	damage_taken.emit(null)
	current_health -= env.power
	GameManager.camera_shake(screen_shake_amount * env.power * 8.0 * env.shake_amount, env.shake_duration, env.shake_addative)
	if current_health <= 0:
		return
	if hit_player:
		hit_player.play_randomized()
	update_healthbar()
	var invulnerability: float = env.cur_invulnerability
	controller.set_damaged(true)
	GameManager.slowdown(env.slowdown, env.slowdown_duration_ms)
	await get_tree().create_timer(max(invulnerability, 0.15)).timeout
	controller.set_damaged(false)
	if !controller || is_queued_for_deletion():
		return
	await get_tree().create_timer(2.0).timeout

func calc_knockback(attack: AttackController) -> void:
	if attack.attack.knockback == 0.0:
		return
	
	var knockback_component: KnockbackComponent = controller.get_component(KnockbackComponent)
	if knockback_component:
		var direction: Vector2 = attack.get_real_velocity().normalized()
		var force: float = attack.attack.knockback
		knockback_component.apply_knockback(direction, force)
	elif "movement" in controller:
		controller.movement.take_knockback(attack.get_real_velocity() * attack.attack.knockback, attack.attack.knockback * 0.1)
		
func reset():
	current_health = max_health
