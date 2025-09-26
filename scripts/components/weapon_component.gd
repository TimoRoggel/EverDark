@tool
class_name WeaponComponent extends SpawnAttackComponent

const HPI: float = PI / 2
const ROTATION_SPEED: float = 25.0

@export var weapon_sprite: Sprite2D = null

var base_offset: Vector2 = Vector2.ZERO
var desired_rotation: float = 0.0
var flipped: bool = false

func _enter() -> void:
	super()
	base_offset = weapon_sprite.offset

func _update(delta: float) -> void:
	if UIManager.paused:
		return
	var new_rotation: float = desired_rotation
	weapon_sprite.rotation = lerp_angle(weapon_sprite.rotation, new_rotation, delta * ROTATION_SPEED)
	flipped = should_flip()
	weapon_sprite.scale.x = -1 if flipped else 1
	weapon_sprite.flip_h = flipped
	weapon_sprite.flip_v = flipped
	weapon_sprite.offset = base_offset * (-1 if flipped else 1)
	attack_angle = weapon_sprite.rotation

func _exit() -> void:
	pass

func should_flip() -> bool:
	return fposmod(weapon_sprite.rotation - HPI, TAU) < PI
