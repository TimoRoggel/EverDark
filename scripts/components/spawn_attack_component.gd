@tool
class_name SpawnAttackComponent extends Component

@export var attack_type: Attack = null
var damaging_flags: int = 2 ** (CharacterController.CharacterFlags.size() - 1) - 1
var sound_player: RandomAudioStreamPlayer2D = null
var attack_angle: float = 0.0
var attacking: bool = false
var attack_timeout: float = 0.0

func _enter() -> void:
	if attack_type and attack_type.attack_sound:
		sound_player = GameManager.create_audio_player(&"sounds", [attack_type.attack_sound])
		add_child(sound_player)

func _update(delta: float) -> void:
	attack_timeout -= delta
	if attacking:
		try_attack()

func _exit() -> void:
	pass

func can_attack() -> bool:
	return attack_timeout <= 0

func try_attack() -> void:
	if can_attack():
		attack()

func attack() -> void:
	if sound_player:
		sound_player.play_randomized()
	attack_timeout = attack_type.firerate

	var kb: KnockbackComponent = controller.get_component(KnockbackComponent)
	if kb:
		kb.apply_knockback(Vector2.from_angle(attack_angle) * attack_type.kickback)

	for i in range(attack_type.count):
		spawn_bullet()

func spawn_bullet() -> void:
	var bullet: AttackController = AttackController.new(attack_type, Vector2.from_angle(attack_angle), controller)
	bullet.global_position = controller.global_position + Vector2(0, -4)
	bullet.damage_flags = damaging_flags
	controller.add_sibling(bullet)
	#print("Spawned attack at ", bullet.global_position)
	
#func spawn_bullet() -> void:
	#var bullet: AttackController = AttackController.new(attack_type, Vector2.from_angle(attack_angle), controller)
	#bullet.global_position = controller.global_position + Vector2(0, -4)
	#bullet.damage_flags = damaging_flags
	#controller.add_sibling(bullet)
	#print("Spawned attack at ", bullet.global_position)
#
	#var kb: KnockbackComponent = controller.get_component(KnockbackComponent)
	#if kb:
		#var recoil_dir = Vector2.from_angle(attack_angle + PI) # opposite of shooting direction
		#kb.apply_knockback(recoil_dir * 800.0, 0.15) # adjust strength and duration
		#print("Recoil applied!")
