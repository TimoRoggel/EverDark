class_name TreeController extends CharacterController

@export var min_recovery_time: float = 20.0
@export var max_recovery_time: float = 60.0
@export var uncut_textures: Array[Texture2D] = []
@export var cut_textures: Array[Texture2D] = []

var health: HealthComponent = null
var index: int = 0

func _ready() -> void:
	super()
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = Generator.game_seed
	index = randomizer.randi_range(0, uncut_textures.size() - 1)
	target_sprite.texture = uncut_textures[index]
	health = get_component(HealthComponent)
	health.died.connect(respawn)

func respawn() -> void:
	target_sprite.texture = cut_textures[index]
	await get_tree().create_timer(randf_range(min_recovery_time, max_recovery_time)).timeout
	health.current_health = health.max_health
	health.alive = true
	target_sprite.texture = uncut_textures[index]
