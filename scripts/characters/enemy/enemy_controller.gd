class_name EnemyController extends CharacterController

@export var charge_time: float = 0.25
@export var min_distance_to_target: float = 8.0
@export var attack_distance: float = 48.0
@export var predictive_attacking: bool = false
@export var stuck_velocity_threshold: float = 5.0
@export var stuck_time_before_unstuck: float = 0.5

var target: TargetComponent = null
var attack: SpawnAttackComponent = null
var movement: MoveComponent = null
var health: HealthComponent = null
var animation: AnimationComponent = null

var charging: bool = false
var stuck_time: float = 0.0

func _init() -> void:
	flags = CharacterFlags.Enemy

func _ready() -> void:
	super()
	#set_damage_color(Color("8b7d9c"))
	target = get_component(TargetComponent)
	attack = get_component(SpawnAttackComponent)
	movement = get_component(MoveComponent)
	health = get_component(HealthComponent)
	health.damage_taken.connect(on_damage_taken)
	animation = get_component(AnimationComponent)

func _custom_process(delta: float) -> void:
	if !health.alive:
		return
	var current_target: CharacterController = get_target()
	var angle_to_target: float = 0.0
	var distance: float = INF
	var vel: Vector2 = get_real_velocity()
	if current_target:
		var intercept_angle: float = prediction_angle()
		if intercept_angle != 0.0 && predictive_attacking:
			angle_to_target = intercept_angle
		else:
			angle_to_target = global_position.angle_to_point(current_target.global_position)
		distance = distance_to_target()
		if !charging:
			attack.attack_angle = angle_to_target
			movement.desired_movement = Vector2.from_angle(angle_to_target)
		else:
			movement.desired_movement = Vector2.ZERO
		if !charging && attack.can_attack() && distance <= attack_distance:
			charging = true
			await get_tree().create_timer(charge_time).timeout
			attack.attack()
			charging = false
		if distance <= min_distance_to_target:
			movement.desired_movement = Vector2.ZERO
			if distance <= min_distance_to_target * 0.5:
				movement.desired_movement = -Vector2.from_angle(angle_to_target)
		if movement.desired_movement.length() > 0.1 && distance > min_distance_to_target:
			if vel.length() < stuck_velocity_threshold:
				stuck_time += delta
			else:
				stuck_time = 0.0
			if stuck_time >= stuck_time_before_unstuck:
				var dir: Vector2 = Vector2.from_angle(angle_to_target)
				var side: float = (1.0 if randf() > 0.5 else -1.0)
				movement.desired_movement = dir.rotated(side * PI * 0.5)
				stuck_time = 0.0
		else:
			stuck_time = 0.0
	else:
		movement.desired_movement = Vector2.ZERO
		stuck_time = 0.0
	if animation:
		var target_direction: Vector2 = animation.direction
		if vel.length() > 1.0:
			target_direction = vel
		elif charging:
			target_direction = Vector2.from_angle(angle_to_target)
		animation.direction = target_direction
		animation.should_flip = target_direction.x < 0.0
		animation.attacking = charging
	super(delta)

func get_target() -> CharacterController:
	return target.target

func on_damage_taken(from: AttackController) -> void:
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
	if !attack:
		return 0.0
	if !attack.attack_type:
		return 0.0
	var current_target: CharacterController = get_target()
	if !current_target:
		return 0.0
	var possible_intercept: Vector2 = calc_intercept(current_target)
	if possible_intercept == Vector2.ZERO:
		return 0.0
	return global_position.angle_to_point(possible_intercept)

func calc_intercept(t: CharacterController) -> Vector2:
	var speed: float = attack.attack_type.speed
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
	if i1 < 0.0 && i2 > 0.0:
		i = i2
	elif i1 > 0.0 && i2 < 0.0:
		i = i2
	elif i1 < i2:
		i = i1
	else:
		i = i2
	var intercept: Vector2 = Vector2(target_position.x + target_speed.x * i, target_position.y + target_speed.y * i)
	return intercept
