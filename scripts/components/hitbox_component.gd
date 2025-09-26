class_name HitboxComponent extends Component

@export var hitbox_area : Area2D
@export var health_component : HealthComponent
@export var damage : int = 10
@export var is_active: bool = true
@export var attack_cooldown: float = 1.0

var already_hit = false

func _enter() -> void:	
	#health_component.damage_taken.connect(damage)
	if hitbox_area:
		hitbox_area.body_entered.connect(_on_body_entered)
	pass

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_body_entered(body: Node2D):
	if not is_active:
		return
	if !already_hit && body.get_node("components/health") && body is ProjectileController:
		take_damage(body)
		cooldown()
		
func take_damage(from):
	if health_component:
		health_component.take_damage(from as ProjectileController)
		
func cooldown():
	already_hit = true
	await get_tree().create_timer(attack_cooldown).timeout
	already_hit = false
