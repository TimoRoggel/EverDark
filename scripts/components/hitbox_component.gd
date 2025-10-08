class_name HitboxComponent extends Component

@export var is_active: bool = true
@export var attack_cooldown_time: float = 0.3
@export var collision_radius: float = 1.0:
	set(value):
		collision_radius = value
		queue_redraw()

var health_component: HealthComponent = null
var block_component: BlockComponent = null
var knockback_component: KnockbackComponent = null

var hurtbox_area: Area2D = Area2D.new()
var hurtbox_collision: CollisionShape2D = CollisionShape2D.new()
var invulnerabilities: Dictionary[Attack, float] = {}
var invulnerable = false

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, collision_radius, Color(0.87, 0.305, 0.418, 0.502))

func _enter() -> void:
	knockback_component = controller.get_component(KnockbackComponent)
	health_component = controller.get_component(HealthComponent)
	block_component = controller.get_component(BlockComponent)

	hurtbox_area.monitoring = true
	hurtbox_area.monitorable = true
	hurtbox_area.collision_layer = 1
	hurtbox_area.collision_mask = 2
	add_child(hurtbox_area)

	hurtbox_collision.shape = CircleShape2D.new()
	hurtbox_collision.shape.radius = collision_radius
	hurtbox_collision.disabled = false
	hurtbox_area.add_child(hurtbox_collision)

	hurtbox_area.body_entered.connect(_on_body_entered)

func _update(delta: float) -> void:
	var new_invulnerabilities: Dictionary[Attack, float] = {}
	for key in invulnerabilities.keys():
		var new_time = invulnerabilities[key] - delta
		if new_time > 0.0:
			new_invulnerabilities[key] = new_time
	invulnerabilities = new_invulnerabilities

func _exit() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if !is_active or invulnerable or !is_instance_of(body, AttackController):
		return
	if invulnerabilities.has(body.attack) and invulnerabilities[body.attack] > 0.0:
		return
	if body.spawner == controller and !body.attack.can_hit_owner:
		return

	invulnerabilities[body.attack] = max(body.attack.invulnerability, 0.3)
	receive_hit(body)

func receive_hit(from: AttackController) -> void:
	if !health_component:
		return
	if block_component and block_component.did_block(global_position.angle_to(from.global_position)):
		return

	print("taken damage:", from.attack.power)
	health_component.take_damage(from)

	if knockback_component:
		knockback_component.apply_backshots(from.global_position, global_position)

	print("Kachoww")
	cooldown()

func cooldown() -> void:
	invulnerable = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	invulnerable = false
