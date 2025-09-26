@tool
class_name SpawnProjectileComponent extends Component

@export var bullet_type: Projectile = null:
	set(value):
		bullet_type = value
		if bullet_type.shoot_sound:
			if sound_player:
				sound_player.samples = [bullet_type.shoot_sound]

var damaging_flags: int = 2 ** (CharacterController.CharacterFlags.size() - 1) - 1:
	set(value):
		damaging_flags = value
		notify_property_list_changed()

var sound_player: RandomAudioStreamPlayer2D = null
var shoot_angle: float = 0.0
var shooting: bool = false
var shoot_timeout: float = 0.0

func _get_property_list():
	return CharacterController.get_flag_properties("damaging_flags")

func _enter() -> void:
	if bullet_type.shoot_sound:
		sound_player = GameManager.create_audio_player(&"sounds", [bullet_type.shoot_sound])
		add_child(sound_player)

func _update(delta: float) -> void:
	shoot_timeout -= delta
	if shooting:
		try_shoot()

func _exit() -> void:
	pass

func can_shoot() -> bool:
	return shoot_timeout <= 0

func try_shoot() -> void:
	if !can_shoot():
		return
	shoot()

func shoot() -> void:
	if sound_player:
		sound_player.play_randomized()
	shoot_timeout = bullet_type.firerate
	controller.movement.add_force(Vector2.from_angle(shoot_angle) * bullet_type.kickback)
	for i: int in range(bullet_type.count):
		spawn_bullet()

func spawn_bullet() -> void:
	var bullet: ProjectileController = ProjectileController.new(bullet_type, Vector2.from_angle(shoot_angle), controller)
	bullet.global_position = controller.global_position + Vector2(0, -4)
	bullet.damage_flags = damaging_flags
	controller.add_sibling(bullet)
