class_name HitboxComponent extends Component

@export var health_component : HealthComponent
@export var is_active: bool = true
@export var attack_cooldown_time: float = 1.0
@export var collision_radius: float = 1.0

var hitbox_area: Area2D = Area2D.new()
var hitbox_collision: CollisionShape2D = CollisionShape2D.new()
var already_hit = false

func _enter() -> void:	
	if hitbox_area && hitbox_collision:
		# setup area2d
		add_child(hitbox_area)
		hitbox_area.add_child(hitbox_collision)
		hitbox_collision.shape = CircleShape2D.new()
		hitbox_collision.shape.radius = collision_radius
		hitbox_area.body_entered.connect(_on_body_entered)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_body_entered(body: Node2D):
	if not is_active:
		return
	if !already_hit && controller.get_component(HealthComponent) && body is ProjectileController:
		take_damage(body)
		cooldown()
		
func take_damage(from):
	if health_component:
		health_component.take_damage(from as ProjectileController)
		
func cooldown():
	already_hit = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	already_hit = false
