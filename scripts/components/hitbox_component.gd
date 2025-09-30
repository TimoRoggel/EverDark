@tool
class_name HitboxComponent extends Component

@export var is_active: bool = true
@export var attack_cooldown_time: float = 1.0
@export var collision_radius: float = 1.0:
	set(value):
		collision_radius = value
		queue_redraw()

var health_component: HealthComponent = null
var block_component: BlockComponent = null
var hurtbox_area: Area2D = Area2D.new()
var hurtbox_collision: CollisionShape2D = CollisionShape2D.new()

var invulnerabilities: Dictionary[Attack, float] = {}
var invulnerable = false

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, collision_radius, Color(0.87, 0.305, 0.418, 0.502))

func _enter() -> void:
	health_component = controller.get_component(HealthComponent)
	block_component = controller.get_component(BlockComponent)
	if hurtbox_area && hurtbox_collision:
		# setup area2d
		hurtbox_area.collision_mask = 2
		add_child(hurtbox_area)
		hurtbox_area.add_child(hurtbox_collision)
		hurtbox_collision.shape = CircleShape2D.new()
		hurtbox_collision.shape.radius = collision_radius
		hurtbox_collision.debug_color = Color(1.0, 0.2, 0.1, 0.4)
		hurtbox_area.body_entered.connect(_on_body_entered)

func _update(delta: float) -> void:
	var new_invulnerabilities: Dictionary[Attack, float] = {}
	for key: Attack in invulnerabilities.keys():
		var new_time: float = invulnerabilities[key] - delta
		if new_time > 0.0:
			new_invulnerabilities[key] = new_time
	invulnerabilities = new_invulnerabilities

func _exit() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if !is_active:
		return
	if invulnerable:
		return
	if !is_instance_of(body, AttackController):
		return
	if invulnerabilities.has(body.attack):
		if invulnerabilities[body.attack] > 0.0:
			return
	if body.spawner == controller:
		if !body.attack.can_hit_owner:
			return
	invulnerabilities[body.attack] = body.attack.invulnerability
	receive_hit(body)

func receive_hit(from: AttackController) -> void:
	if !health_component:
		return
	if block_component:
		if block_component.did_block(global_position.angle_to(from.global_position)):
			return
	print("taken damage: ", from.attack.power)
	health_component.take_damage(from)
	cooldown()

func can_receive_damage() -> bool:
	return is_active && !invulnerable

func cooldown() -> void:
	invulnerable = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	invulnerable = false
