class_name TreeController extends CharacterController

@export var min_recovery_time: float = 40.0
@export var max_recovery_time: float = 120.0
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
	SaveSystem.track(name, get_tree_data, set_tree_data.call_deferred, {"health": health.max_health})

func respawn(time: float = get_recovery_time()) -> void:
	target_sprite.texture = cut_textures[index]
	await get_tree().create_timer(time).timeout
	health.current_health = health.max_health
	health.alive = true
	target_sprite.texture = uncut_textures[index]

func get_recovery_time() -> float:
	return randf_range(min_recovery_time, max_recovery_time)

func get_tree_data() -> Dictionary:
	return {"health": health.current_health}

func set_tree_data(data: Dictionary) -> void:
	if data.is_empty():
		return
	health.set_health_no_drops(data["health"])
