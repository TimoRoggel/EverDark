@tool
class_name EntitySpawner extends Node2D

const TRIES: int = 20

@export var entity: Entity = null
@export_range(0, 80) var capacity: int = 4
@export_range(0, 80) var amount: int = 1
## Beyond this distance from (0,0) the entity spawn rate is at its lowest.
@export var max_spawn_distance: float = 6400.0
## At (0,0) this is the spawn rate (spawns 1 entity per [member min_spawn_rate] seconds), at [member max_spawn_distance] this value is 0.1%.
@export_range(0.0, 800.0, 0.01) var min_spawn_rate: float = 1.0
## How long until the first entity spawns when the game starts.
@export_range(0.0, 1.0, 0.01) var randomness: float = 0.0
@export var min_radius: float = 250.0:
	set(value):
		min_radius = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var max_radius: float = 500.0:
	set(value):
		max_radius = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var entitiy_spawn_wait_time: float = 30.0 

var spawn_timer: Timer = null
var spawned_entities: Array[Node2D] = []
var enemies_just_reset: bool = false
var dead: bool = false

var entity_health := 0.0
var entity_speed := 0.0

var previous_difficulty := -1

func _ready() -> void:
	set_entity_properties()
	if Engine.is_editor_hint():
		return
	spawn_timer = Timer.new()
	spawn_timer.one_shot = true
	add_child(spawn_timer)
	spawn_timer.timeout.connect(spawn)
	spawn_timer.start(0.01)

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, min_radius, Color(0.077, 0.265, 0.452, 0.25))
	draw_circle(Vector2.ZERO, min_radius, Color(0.077, 0.265, 0.452, 0.25), false, -8.0)
	draw_circle(Vector2.ZERO, max_radius, Color(0.0, 0.5, 1.0, 0.25))
	draw_circle(Vector2.ZERO, max_radius, Color(0.0, 0.5, 1.0, 0.5), false, -8.0)

func spawn() -> void:
	if spawned_entities.size() < capacity:
		for i: int in range(min(int(ceil(GameManager.get_randomized_value(amount, randomness))), capacity - spawned_entities.size())):
			spawn_entity()
	restart_timer()

func _physics_process(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	if GameManager.player:
		if GameManager.player.death:
			if dead != GameManager.player.death.is_dead:
				dead = GameManager.player.death.is_dead
			if GameManager.player.death.is_dead:
				if !enemies_just_reset:
					reset_enemies()
					enemies_just_reset = true
					await get_tree().create_timer(1.0).timeout
					enemies_just_reset = false
					
func _process(delta: float) -> void:
	if previous_difficulty != GameSettings.current_difficulty:
		reset_entities()
		previous_difficulty = GameSettings.current_difficulty

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
	create_entity(spawn_position)

func create_entity(spawn_position: Vector2, health: float = 0.0) -> void:
	set_entity_properties()
	var spawned_entity: Node2D = entity.scene.instantiate()
	spawned_entity.global_position = spawn_position
	spawned_entity.set("spawn_origin", spawn_position)
	get_tree().current_scene.add_child(spawned_entity)
	spawned_entity.tree_exiting.connect(func() -> void:
		spawned_entities.erase(spawned_entity)
		if spawn_timer:
			spawn_timer.stop()
			restart_timer()
	)
	spawned_entities.append(spawned_entity)
	await get_tree().create_timer(0.2).timeout
	spawned_entity.health.current_health = entity_health
	if spawned_entity.movement:
		spawned_entity.movement.sprint_speed = entity_speed
	await get_tree().create_timer(120.0, false).timeout
	if !spawned_entity:
		return
	if spawned_entity.is_queued_for_deletion():
		return
	spawned_entity.queue_free()

func reset_enemies() -> void:
	for enemy in spawned_entities:
		if !is_instance_valid(enemy):
			continue
		var spawn_position: Vector2 = get_randomized_spawn_location()
		for i in TRIES:
			if Generator.is_in_everdark(spawn_position):
				break
			spawn_position = get_randomized_spawn_location()
		enemy.global_position = spawn_position
		await get_tree().create_timer(1.0).timeout
		
func despawn_enemies() -> void:
	for enemy in spawned_entities:
		if not is_instance_valid(enemy):
			continue
		enemy.queue_free()
	spawn_timer.stop()
	await get_tree().create_timer(entitiy_spawn_wait_time).timeout
	spawn_timer.start()

func restart_timer() -> void:
	spawn_timer.start(GameManager.get_randomized_value(get_spawn_rate(), randomness))

func get_spawn_rate() -> float:
	return min_spawn_rate

func get_randomized_spawn_location() -> Vector2:
	var theta: float = randf_range(0, TAU)
	var d: float = sqrt(randf_range(0.0, 1.0)) * (max_radius - min_radius) + min_radius
	var x: float = global_position.x + d * cos(theta)
	var y: float = global_position.y + d * sin(theta)
	return Vector2(x, y)

func get_entity_data() -> Dictionary:
	var data: Dictionary = {}
	data["time"] = spawn_timer.time_left
	data["entities"] = []
	for e: EnemyController in spawned_entities:
		if !e.health:
			continue
		data["entities"].append({"health": e.health.current_health, "position": e.global_position})
	return data

func set_entity_data(data: Dictionary) -> void:
	if spawned_entities.size() > 0:
		return
	if data.is_empty():
		spawn_timer.start(initial_spawn_rate)
		return
	for d: Dictionary in data["entities"]:
		create_entity(d["position"], d["health"])
	spawn_timer.start(data["time"])

func set_entity_properties():
	var properties = GameSettings.difficulty_settings[GameSettings.current_difficulty]
	entity_health = properties.enemy_health
	entity_speed = properties.sprint_speed
	min_radius = properties.min_radius
	max_radius = properties.max_radius

func reset_entities():
	if !spawned_entities.is_empty():
		for entity in spawned_entities:
			entity.health.current_health = entity_health
			entity.movement.sprint_speed = entity_speed
