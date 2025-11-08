@tool
class_name SpawnAttackComponent extends Component

@export var attack_id: int = 0

var attack_type: Attack = null
var damaging_flags: int = 2 ** (CharacterController.CharacterFlags.size() - 1) - 1:
	set(value):
		damaging_flags = value
		notify_property_list_changed()

var sound_player: RandomAudioStreamPlayer2D = null
var attack_angle: float = 0.0
var attacking: bool = false
var attack_timeout: float = 0.0

func _get_property_list() -> Array[Dictionary]:
	return CharacterController.get_flag_properties("damaging_flags")

func _enter() -> void:
	attack_type = DataManager.get_resource_by_id("attacks", attack_id)
	if !attack_type:
		return
	if attack_type.attack_sound:
		sound_player = GameManager.create_audio_player(&"SFX", [attack_type.attack_sound], self)

func _update(delta: float) -> void:
	attack_timeout -= delta
	if attacking:
		try_attack()

func _exit() -> void:
	pass

func can_attack() -> bool:
	return attack_timeout <= 0

func try_attack() -> void:
	if !can_attack():
		return
	attack()

func attack() -> void:
	if sound_player:
		sound_player.play_randomized()
	attack_timeout = attack_type.firerate
	controller.movement.add_force(Vector2.from_angle(attack_angle) * attack_type.kickback)
	for i: int in range(attack_type.count):
		spawn_bullet()

func spawn_bullet() -> void:
	var bullet: AttackController = AttackController.new(attack_type, Vector2.from_angle(attack_angle), controller)
	bullet.damage_flags = damaging_flags
	if attack_type.attached_to_owner:
		controller.add_child(bullet)
	else:
		bullet.global_position = controller.global_position
		controller.add_sibling(bullet)
	bullet.position += Vector2(0, -4)
