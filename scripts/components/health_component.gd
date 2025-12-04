class_name HealthComponent extends Component

@export var max_health: float = 10.0
@export var death_sounds: Array[AudioStream] = []
@export var persistent: bool = false
@export var death_drops: Array[int] = []
@export var death_drop_odds: Array[int] = []

var current_health: float = max_health:
	set(value):
		current_health = value
		health_changed.emit(value)
var alive: bool = true
var death_player: RandomAudioStreamPlayer2D = null
var screen_shake_amount: float = 0.5
var hitbox: HitboxComponent = null

signal damage_taken(from: AttackController)
signal died
signal health_changed(new_value: float)

func _enter() -> void:
	current_health = max_health
	# Audio
	if death_sounds.size() > 0:
		death_player = GameManager.create_audio_player(&"SFX", death_sounds, self)
	await get_tree().physics_frame
	hitbox = controller.get_component(HitboxComponent)

func _update(_delta: float) -> void:
	if current_health <= 0:
		death()

func _exit() -> void:
	pass

func set_health_no_drops(new_health: float) -> void:
	current_health = new_health
	if current_health <= 0:
		alive = false
		died.emit()
		if persistent:
			return
		controller.process_mode = Node.PROCESS_MODE_DISABLED
		controller.queue_free()

func death() -> void:
	if is_queued_for_deletion():
		return
	if !alive:
		return
	alive = false
	if !persistent:
		controller.visible = false
	for i: int in death_drops.size():
		var item_id: int = death_drops[i]
		var odds: int = death_drop_odds[i] if death_drop_odds.size() > i else 100
		if randi_range(0, 100) > odds:
			continue
		DroppedItem2D.drop(item_id, 1, global_position)
	died.emit()
	if !persistent:
		controller.collision_layer = 0
	if death_player:
		death_player.play_randomized()
		await death_player.finished
	if !persistent:
		controller.process_mode = Node.PROCESS_MODE_DISABLED
		controller.queue_free()

func can_get_damaged(attack: AttackController) -> bool:
	return alive && (controller.flags & attack.damage_flags) == controller.flags

func take_damage(attack: AttackController) -> void:
	if !can_get_damaged(attack):
		return
	var proj: Attack = attack.attack
	damage_taken.emit(attack)
	current_health -= proj.power
	GameManager.camera_shake(screen_shake_amount * proj.power * 8.0 * proj.shake_amount, proj.shake_duration, proj.shake_addative)
	if current_health <= 0:
		return
	if controller is PlayerController:
		controller.hud.animate_healthbar_color_change(Color(1.0, 0.0, 0.0, 1.0))
	calc_knockback(attack)
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
	controller.hud.animate_healthbar_color_change(Color(.7,0,0))
	controller.set_damaged(true)
	await get_tree().create_timer(.5).timeout
	var invulnerability: float = env.cur_invulnerability
	GameManager.slowdown(env.slowdown, env.slowdown_duration_ms)
	await get_tree().create_timer(max(invulnerability, 0.15)).timeout
	controller.set_damaged(false)
	if !controller || is_queued_for_deletion():
		return
	await get_tree().create_timer(2.0).timeout

func take_damage_anim() -> void:
	controller.set_damaged(true)
	hitbox.play_damaged()
	await get_tree().create_timer(0.25).timeout
	controller.set_damaged(false)

func heal(amount: float = 1.0):
	current_health += amount
	if current_health == max_health:
		return
	if amount < 0:
		take_damage_anim()
	controller.hud.animate_healthbar_color_change(Color(1.0, 0.0, 0.0, 1.0))

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
