class_name HurtboxComponent extends Component

@export var is_active: bool = true
@export var attack_cooldown_time: float = 1.0
@export var collision_radius: float = 1.0

var health_component : HealthComponent
var hurtbox_area: Area2D = Area2D.new()
var hurtbox_collision: CollisionShape2D = CollisionShape2D.new()
var already_hurt = false

func _enter() -> void:	
	health_component = controller.get_component(HealthComponent)
	if hurtbox_area && hurtbox_collision:
		# setup area2d
		add_child(hurtbox_area)
		hurtbox_area.add_child(hurtbox_collision)
		hurtbox_collision.shape = CircleShape2D.new()
		hurtbox_collision.shape.radius = collision_radius
		hurtbox_area.body_entered.connect(_on_body_entered)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_body_entered(body: Node2D):
	if not is_active:
		return
	if !already_hurt && body is HitboxComponent:
		receive_hit(body)
		
func receive_hit(from: ProjectileController):
	if health_component:
		health_component.take_damage(from as ProjectileController)
		cooldown()
	
func can_receive_damage() -> bool:
	return is_active and not already_hurt
		
func cooldown():
	already_hurt = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	already_hurt = false
