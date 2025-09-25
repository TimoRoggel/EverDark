class_name HitboxComponent extends Component

@export var health_component : HealthComponent

func _enter() -> void:	
	health_component.damage_taken.connect(damage)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func damage(from):
	if health_component:
		health_component.take_damage(from as ProjectileController)
