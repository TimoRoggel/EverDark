class_name HitboxComponent extends Component

@export var invincible: bool = true
@export var damage: int = 10
@export var collision_radius: float = 1.0
@export var attack_duration: float = 0.2

var hitbox_area: Area2D = Area2D.new()
var hitbox_collision: CollisionShape2D = CollisionShape2D.new()
var already_hit_targets: Array = []

func _enter() -> void:
	if hitbox_area && hitbox_collision:
		add_child(hitbox_area)
		hitbox_area.add_child(hitbox_collision)
		hitbox_collision.shape = CircleShape2D.new()
		hitbox_collision.shape.radius = collision_radius
		hitbox_area.area_entered.connect(_on_area_entered)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func _on_area_entered(area: Area2D):
	if not invincible:
		return
	if area in already_hit_targets:
		return
	if area.get_parent() is HurtboxComponent:
		var hurtbox = area.get_parent() as HurtboxComponent
		if hurtbox.is_active:
			hurtbox.take_damage(self)
		already_hit_targets.append(area)

func activate():
	invincible = true
	already_hit_targets.clear()
	await get_tree().create_timer(attack_duration).timeout
	invincible = false
