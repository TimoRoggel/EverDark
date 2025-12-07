@tool
class_name HitboxComponent extends Component

@export var is_active: bool = true
@export var attack_cooldown_time: float = 1.0
@export var collision_radius: float = 1.0:
	set(value):
		collision_radius = value
		if hurtbox_collision and hurtbox_collision.shape is CircleShape2D:
			hurtbox_collision.shape.radius = value
		queue_redraw()
@export var damage_sounds: Array[AudioStream] = []
@export var minimum_harvest_level_filter: int = 0
@export_flags("Pickaxe", "Axe") var damage_flag_filters: int = 0
@export_flags_2d_physics var hurtbox_collision_layer: int = 1
@export_flags_2d_physics var hurtbox_collision_mask: int = 2

var health_component: HealthComponent = null
var block_component: BlockComponent = null
var hurtbox_area: Area2D = Area2D.new()
var hurtbox_collision: CollisionShape2D = CollisionShape2D.new()

var invulnerabilities: Dictionary[Attack, float] = {}
var invulnerable: bool = false
var damage_sound_player: RandomAudioStreamPlayer2D = null

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, collision_radius, Color(0.87, 0.305, 0.418, 0.502))

func _enter() -> void:
	damage_sound_player = GameManager.create_audio_player(&"SFX", damage_sounds, self)
	health_component = controller.get_component(HealthComponent)
	block_component = controller.get_component(BlockComponent)
	if hurtbox_area && hurtbox_collision:
		# setup area2d
		hurtbox_area.collision_layer = hurtbox_collision_layer
		hurtbox_area.collision_mask = hurtbox_collision_mask
		add_child(hurtbox_area)
		hurtbox_area.add_child(hurtbox_collision)
		hurtbox_collision.shape = CircleShape2D.new()
		hurtbox_collision.shape.radius = collision_radius
		hurtbox_collision.debug_color = Color(1.0, 0.2, 0.1, 0.4)
		hurtbox_area.body_entered.connect(_on_body_entered)

func _update(delta: float) -> void:
	var new_invulnerabilities: Dictionary[Attack, float] = {}
	for key: Attack in invulnerabilities.keys():
		var new_time: float = invulnerabilities[key] - delta
		if new_time > 0.0:
			new_invulnerabilities[key] = new_time
	invulnerabilities = new_invulnerabilities

func _exit() -> void:
	pass

func _on_body_entered(body: Node2D) -> void:
	if !is_active:
		return
	if invulnerable:
		return
	if !is_instance_of(body, AttackController):
		return
	if invulnerabilities.has(body.attack):
		if invulnerabilities[body.attack] > 0.0:
			return
	if body.spawner == controller:
		if !body.attack.can_hit_owner:
			return
	invulnerabilities[body.attack] = body.attack.invulnerability
	receive_hit(body)

func receive_hit(from: AttackController) -> void:
	if !health_component:
		return
	if !health_component.can_get_damaged(from):
		return
	if from.attack.harvest_level < minimum_harvest_level_filter:
		return
	if from.attack.flags & damage_flag_filters != damage_flag_filters:
		return
	if block_component:
		if block_component.did_block(global_position.angle_to(from.global_position)):
			return
	play_damaged()
	health_component.take_damage(from)
	cooldown()

func play_damaged() -> void:
	if damage_sound_player:
		damage_sound_player.play_randomized()

func can_receive_damage() -> bool:
	return is_active && !invulnerable

func cooldown() -> void:
	invulnerable = true
	await get_tree().create_timer(attack_cooldown_time).timeout
	invulnerable = false
