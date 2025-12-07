@tool
class_name GuardianSpawner
extends EntitySpawner

@export var boss_health: float = 1000.0
@export var boss_min_power: float = 100.0
@export var boss_max_power: float = 100.0

var boss_spawned: bool = false

func _ready() -> void:
	super()
	if Engine.is_editor_hint():
		return
	capacity = 1
	amount = 1

func spawn() -> void:
	if boss_spawned:
		return
	if spawned_entities.size() < 1:
		await spawn_entity()
		boss_spawned = true

func spawn_entity() -> void:
	if get_tree().paused:
		return

	var spawn_position: Vector2 = Vector2.ZERO
	for i: int in TRIES:
		spawn_position = get_randomized_spawn_location()
		if Generator.is_in_everdark(spawn_position):
			break
		if i == TRIES - 1:
			return

	if entity.spawn_particles:
		var particles: Node2D = entity.spawn_particles.instantiate()
		particles.global_position = spawn_position
		get_tree().current_scene.add_child(particles)
		await get_tree().create_timer(entity.time_to_spawn, false).timeout

	var spawned_entity: Node2D = entity.scene.instantiate()
	spawned_entity.global_position = spawn_position
	get_tree().current_scene.add_child(spawned_entity)

	spawned_entity.tree_exiting.connect(func() -> void: spawned_entities.erase(spawned_entity))
	spawned_entities.append(spawned_entity)

	if spawned_entity is CharacterController:
		var cc := spawned_entity as CharacterController

		var health_comp: HealthComponent = cc.get_component(HealthComponent)
		if health_comp:
			health_comp.max_health = boss_health
			health_comp.current_health = boss_health
			if "update_healthbar" in health_comp:
				health_comp.update_healthbar()

		var attack_comp: SpawnAttackComponent = cc.get_component(SpawnAttackComponent)
		if attack_comp:
			attack_comp.min_power = boss_min_power
			attack_comp.max_power = boss_max_power
