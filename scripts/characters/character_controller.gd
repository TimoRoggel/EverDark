class_name CharacterController extends CharacterBody2D

const SHADER: Shader = preload("uid://bgun8c6p8w1no")

enum CharacterFlags {
	None,
	Player,
	Enemy
} 

@export var bounciness: float = 1.0
@export var bump_sounds: Array[AudioStream] = []

var components: Array[Component] = []
var flags: int = 0
var should_bounce_conditions: Array[Callable] = []
var bump_player: RandomAudioStreamPlayer2D = null

static func get_flag_properties(property: String) -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var character_flags: Array = CharacterController.CharacterFlags.keys()
	character_flags.remove_at(0)
	properties.append({
		"name": property,
		"type": TYPE_INT,
		"hint": PROPERTY_HINT_FLAGS,
		"hint_string": ",".join(character_flags),
	})

	return properties

func _ready() -> void:
	material = ShaderMaterial.new()
	material.shader = SHADER
	set_damage_color(Color("FBF5EF"))
	load_components()
	bump_player = GameManager.create_audio_player(&"sounds", bump_sounds)
	add_child(bump_player)

func _custom_process(_delta: float) -> void:
	pass

func _custom_physics_process(_delta: float) -> void:
	pass

func _process(delta: float) -> void:
	for c: Component in components:
		if !c.updates_in_physics:
			c._update(delta)
	_custom_process(delta)

func _physics_process(delta: float) -> void:
	for c: Component in components:
		if c.updates_in_physics:
			c._update(delta)
	_custom_physics_process(delta)
	if should_bounce() && bounciness != 0.0 && is_on_wall() && abs(velocity.length()) > 0.0:
		var bounce: Vector2 = 2.0 * velocity.dot(get_wall_normal()) * get_wall_normal() * bounciness
		velocity -= bounce
		var bounce_amount: float = bounce.length()
		if !bump_sounds.is_empty() && abs(bounce_amount) > 0.5:
			bump_player.base_volume = linear_to_db(abs(bounce_amount) * 0.01)
			bump_player.play_randomized()
		on_bounce(bounce_amount)
	move_and_slide()

func _exit_tree() -> void:
	for c: Component in components:
		c._exit()

func on_bounce(_bounce_amount: float) -> void:
	pass

func load_components(parent: Node = self) -> void:
	for c: Node in parent.get_children():
		if is_instance_of(c, Component):
			components.append(c)
			c.initialize(self)
		load_components(c)

func get_component(type: Variant, index: int = 0) -> Component:
	var count: int = 0
	for c: Component in components:
		if is_instance_of(c, type):
			if count == index:
				return c
			count += 1
	return null

func set_damaged(damaged: bool) -> void:
	material.set_shader_parameter("damaged", damaged)

func set_damage_color(damage_color: Color) -> void:
	material.set_shader_parameter("damage_color", damage_color)

func should_bounce() -> bool:
	for c: Callable in should_bounce_conditions:
		if c.call():
			return true
	return false
