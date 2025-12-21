@tool
class_name SpawnAttackComponent extends Component

@export var attack_id: int = 0:
	set(value):
		attack_id = value
		if !Engine.is_editor_hint():
			_init_attack_type()

@export var min_power: float = 0.1
@export var max_power: float = 1.0

var attack_type: Attack = null
var damaging_flags: int = 2 ** (CharacterController.CharacterFlags.size() - 1) - 1:
	set(value):
		damaging_flags = value
		notify_property_list_changed()

var sound_player: RandomAudioStreamPlayer2D = null
var attack_angle: float = 0.0
var attacking: bool = false
var attack_timeout: float = 0.0
var attack_active: bool = false

func _get_property_list() -> Array[Dictionary]:
	return CharacterController.get_flag_properties("damaging_flags")

func _init_attack_type() -> void:
	attack_type = DataManager.get_resource_by_id("attacks", attack_id)
	if attack_type && attack_type.attack_sound:
		sound_player = GameManager.create_audio_player(&"SFX", [attack_type.attack_sound], self)

func _enter() -> void:
	if Engine.is_editor_hint():
		return
	if attack_type == null:
		_init_attack_type()

func _update(delta: float) -> void:
	attack_timeout -= delta
	if attacking:
		try_attack()

func _exit() -> void:
	pass

func can_attack() -> bool:
	if attack_id < 0:
		return false
	if attack_type == null:
		_init_attack_type()
		if attack_type == null:
			return false
	if attack_type.cost > -1:
		if controller.inventory:
			if !controller.inventory.has(attack_type.cost):
				return false
	return attack_timeout <= 0

func try_attack() -> void:
	if !can_attack():
		return
	attack()

func attack() -> void:
	if attack_type == null:
		return
	if attack_type.cost > -1:
		if controller.inventory:
			controller.inventory.remove(attack_type.cost)
	attack_active = true
	if sound_player:
		sound_player.play_randomized()
	attack_timeout = attack_type.firerate
	controller.movement.add_force(Vector2.from_angle(attack_angle) * attack_type.kickback)
	for i: int in attack_type.count - 1:
		spawn_bullet()
	await spawn_bullet()
	attack_active = false

func spawn_bullet() -> void:
	if attack_type == null:
		return
	var temp_attack_data = attack_type.duplicate()
	temp_attack_data.power = randf_range(min_power, max_power)
	var bullet: AttackController = AttackController.new(temp_attack_data, Vector2.from_angle(attack_angle), controller)

	bullet.damage_flags = damaging_flags
	if attack_type.attached_to_owner:
		controller.add_child(bullet)
	else:
		bullet.global_position = controller.global_position
		controller.add_sibling(bullet)
	bullet.position += Vector2(0, -4)
	await bullet.death
