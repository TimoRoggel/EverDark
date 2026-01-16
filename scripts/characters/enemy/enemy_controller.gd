class_name EnemyController extends CharacterController

@export var charge_time: float = 0.25
@export var min_distance_to_target: float = 8.0
@export var attack_distance: float = 48.0
@export var max_wander_distance: float = 48.0
@export var hard_leash_multiplier: float = 5.0
@export var predictive_attacking: bool = false

@export var force_return_to_spawn: bool = false

@export var skirmisher_mode: bool = false
@export var orbit_start_distance: float = 120.0 
@export var preferred_orbit_distance: float = 80.0   
@export var orbit_strength: float = 1.0              
@export var orbit_switch_interval: float = 1.2        
@export var post_attack_retreat_time: float = 0.35  

@export var dash_sidestep_enabled: bool = false
@export var dash_sidestep_chance: float = 0.35 
@export var dash_sidestep_cooldown: float = 2.0  
@export var dash_sidestep_duration: float = 0.12 
@export var dash_sidestep_min_distance: float = 40.0 
@export var dash_sidestep_max_distance: float = 150.0
@export var dash_prefer_when_can_attack: bool = true

var target: TargetComponent = null
var attack: SpawnAttackComponent = null
var movement: MoveComponent = null
var health: HealthComponent = null
var animation: AnimationComponent = null

var charging: bool = false
var returning_home: bool = false
var spawn_origin: Vector2 = Vector2.ZERO

var _orbit_dir: int = 1
var _orbit_switch_timer: float = 0.0
var _retreat_timer: float = 0.0

var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_dir: Vector2 = Vector2.ZERO

func _get_property_list() -> Array:
	var properties: Array = []
	return properties

func _ready() -> void:
	super()
	target = get_component(TargetComponent)
	attack = get_component(SpawnAttackComponent)
	movement = get_component(MoveComponent)
	health = get_component(HealthComponent)
	animation = get_component(AnimationComponent)

	if health:
		health.damage_taken.connect(on_damage_taken)

	if Engine.has_singleton("GameManager") and GameManager:
		GameManager.ending.connect(func() -> void:
			if health:
				health.current_health = 0.0
		)

	if force_return_to_spawn:
		if has_method("get"):
			if get("spawn_origin") != null:
				spawn_origin = get("spawn_origin")
		if spawn_origin == Vector2.ZERO:
			spawn_origin = global_position

	randomize()
	_orbit_dir = (randi() % 2) * 2 - 1 

func _custom_process(delta: float) -> void:
	if !health or !health.alive:
		return
	if !movement or !target:
		return

	_orbit_switch_timer = maxf(0.0, _orbit_switch_timer - delta)
	_retreat_timer = maxf(0.0, _retreat_timer - delta)
	_dash_timer = maxf(0.0, _dash_timer - delta)
	_dash_cooldown_timer = maxf(0.0, _dash_cooldown_timer - delta)

	var current_target: CharacterController = get_target()
	var has_target: bool = current_target != null and is_instance_valid(current_target) and !current_target.is_queued_for_deletion()

	if force_return_to_spawn and spawn_origin != Vector2.ZERO:
		var d: float = global_position.distance_to(spawn_origin)

		if returning_home and has_target:
			if target:
				target.clear_target()
			has_target = false
			current_target = null

		if has_target and hard_leash_multiplier > 0.0 and d > max_wander_distance * hard_leash_multiplier:
			if target:
				target.clear_target()
			has_target = false
			current_target = null
			returning_home = true

		if !has_target:
			if d > max_wander_distance:
				returning_home = true
			if returning_home:
				var dir_home: Vector2 = (spawn_origin - global_position).normalized()
				movement.desired_movement = dir_home
				_apply_animation(dir_home, false)
				if d < max_wander_distance * 0.4:
					returning_home = false
				super(delta)
				return
		else:
			returning_home = false

	if !has_target:
		movement.desired_movement = Vector2.ZERO
		_apply_animation(Vector2.ZERO, charging)
		super(delta)
		return

	var angle_to_target: float = 0.0
	var distance: float = distance_to_target()

	var intercept_angle: float = prediction_angle()
	if intercept_angle != 0.0 and predictive_attacking:
		angle_to_target = intercept_angle
	else:
		angle_to_target = global_position.angle_to_point(current_target.global_position)

	if charging:
		movement.desired_movement = Vector2.ZERO
	else:
		var desired: Vector2 = target.get_target_direction()

		if skirmisher_mode:
			desired = _compute_skirmisher_movement(current_target, distance)

		if dash_sidestep_enabled and _dash_timer > 0.0 and _dash_dir != Vector2.ZERO:
			desired = _dash_dir

		movement.desired_movement = desired

	if attack and !charging and attack.can_attack() and distance <= attack_distance:
		charging = true
		attack.attack_angle = angle_to_target

		await get_tree().create_timer(charge_time).timeout
		if !is_instance_valid(self) or !health.alive:
			return

		attack.attack_angle = angle_to_target
		attack.attack()

		charging = false

		if skirmisher_mode and post_attack_retreat_time > 0.0:
			_retreat_timer = post_attack_retreat_time

	if !skirmisher_mode:
		if distance <= min_distance_to_target:
			movement.desired_movement = Vector2.ZERO
			if distance <= min_distance_to_target * 0.5:
				movement.desired_movement = -Vector2.from_angle(angle_to_target)

	var anim_dir: Vector2 = Vector2.from_angle(angle_to_target) if movement.desired_movement.is_zero_approx() else movement.desired_movement
	_apply_animation(anim_dir, charging)

	if animation and animation.animated_sprite and animation.animated_sprite.animation.begins_with(animation.ANIMS[2]):
		movement.desired_movement = Vector2.ZERO

	super(delta)

func _compute_skirmisher_movement(t: CharacterController, distance: float) -> Vector2:
	var to_target: Vector2 = (t.global_position - global_position)
	var dir_to: Vector2 = to_target.normalized()
	if dir_to == Vector2.ZERO:
		return Vector2.ZERO

	if _orbit_switch_timer <= 0.0:
		if randf() < 0.25:
			_orbit_dir *= -1
		_orbit_switch_timer = orbit_switch_interval

	if _retreat_timer > 0.0:
		return -dir_to

	if distance > orbit_start_distance:
		return dir_to

	var tangent: Vector2 = dir_to.rotated(PI * 0.5) * float(_orbit_dir)

	var correction: Vector2 = Vector2.ZERO
	if preferred_orbit_distance > 0.0:
		var error: float = distance - preferred_orbit_distance
		correction = dir_to * clampf(error / maxf(preferred_orbit_distance, 1.0), -1.0, 1.0)

	var move: Vector2 = tangent * orbit_strength + correction

	_try_start_dash(dir_to, tangent, distance)

	return move.normalized()

func _try_start_dash(dir_to: Vector2, tangent: Vector2, distance: float) -> void:
	if !dash_sidestep_enabled:
		return
	if charging:
		return
	if _dash_timer > 0.0:
		return
	if _dash_cooldown_timer > 0.0:
		return
	if distance < dash_sidestep_min_distance or distance > dash_sidestep_max_distance:
		return

	var chance := dash_sidestep_chance
	if dash_prefer_when_can_attack and attack and distance <= attack_distance * 1.2:
		chance = minf(0.9, chance + 0.25)

	if randf() > chance:
		return

	var dash_dir := tangent
	if randf() < 0.15:
		dash_dir = -dash_dir

	_dash_dir = dash_dir.normalized()
	_dash_timer = dash_sidestep_duration
	_dash_cooldown_timer = dash_sidestep_cooldown

func _apply_animation(dir: Vector2, is_attacking: bool) -> void:
	if !animation:
		return
	animation.direction = dir
	animation.should_flip = animation.direction.x < 0.0
	animation.attacking = is_attacking

func get_target() -> CharacterController:
	return target.target if target else null

func on_damage_taken(from: AttackController) -> void:
	if force_return_to_spawn and returning_home:
		return
	if !target or target.is_queued_for_deletion():
		return
	if !is_instance_valid(from):
		return
	if !from.spawner or !is_instance_valid(from.spawner):
		return
	target.try_add_target(from.spawner)

func distance_to_target() -> float:
	var current_target: CharacterController = get_target()
	if !current_target:
		return INF
	return current_target.global_position.distance_to(global_position)

func prediction_angle() -> float:
	var current_target: CharacterController = get_target()
	if !current_target:
		return 0.0
	var possible_intercept: Vector2 = calc_intercept(current_target)
	if possible_intercept == Vector2.ZERO:
		return 0.0
	return global_position.angle_to_point(possible_intercept)

func calc_intercept(t: CharacterController) -> Vector2:
	if !attack or !attack.attack_type:
		return Vector2.ZERO

	var speed: float = attack.attack_type.speed
	if speed <= 0.0:
		return Vector2.ZERO

	var target_speed: Vector2 = t.get_real_velocity()
	var target_position: Vector2 = t.global_position + target_speed
	var dist_x: float = target_position.x - global_position.x
	var dist_y: float = target_position.y - global_position.y
	var a: float = pow(speed, 2) - (pow(target_speed.x, 2) + pow(target_speed.y, 2))
	var b: float = 2 * (dist_x * target_speed.x + dist_y * target_speed.y)
	var c: float = pow(dist_x, 2) + pow(dist_y, 2)
	var da: float = 2 * a
	var cb: float = pow(b, 2) - 4 * a * c
	if cb < 0:
		return Vector2.ZERO
	var ccb: float = sqrt(cb)
	var i1: float = (-b + ccb) / da
	var i2: float = (-b - ccb) / da
	var i: float = 0.0
	if i1 < 0.0 and i2 > 0.0:
		i = i2
	elif i1 > 0.0 and i2 < 0.0:
		i = i2
	elif i1 < i2:
		i = i1
	else:
		i = i2
	var intercept: Vector2 = Vector2(target_position.x + target_speed.x * i, target_position.y + target_speed.y * i)
	return intercept
