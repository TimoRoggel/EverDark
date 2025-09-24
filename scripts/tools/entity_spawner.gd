@tool
class_name EntitySpawner extends Node2D

@export var entity: Entity = null
@export_range(0, 80) var capacity: int = 4
@export_range(0, 80) var amount: int = 1
@export_range(0.0, 800.0, 0.01) var spawn_rate: float = 1.0
@export_range(0.0, 1.0, 0.01) var randomness: float = 0.0
@export var radius: float = 160.0:
	set(value):
		radius = value
		if Engine.is_editor_hint():
			queue_redraw()

var spawn_timer: Timer = null
var spawned_entities: Array[Node2D] = []

func _ready() -> void:
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
	draw_circle(Vector2.ZERO, radius, Color(0.0, 0.5, 1.0, 0.25))
	draw_circle(Vector2.ZERO, radius, Color(0.0, 0.5, 1.0, 0.5), false, -8.0)

func spawn() -> void:
	if spawned_entities.size() < capacity:
		for i: int in range(min(int(ceil(GameManager.get_randomized_value(amount, randomness))), capacity - spawned_entities.size())):
			spawn_entity()
	restart_timer()

func spawn_entity() -> void:
	var spawn_position: Vector2 = get_randomized_spawn_location()
	var particles: Node2D = entity.spawn_particles.instantiate()
	particles.global_position = spawn_position
	get_tree().current_scene.add_child(particles)
	await get_tree().create_timer(entity.time_to_spawn, false).timeout
	var spawned_entity: Node2D = entity.scene.instantiate()
	spawned_entity.global_position = spawn_position
	get_tree().current_scene.add_child(spawned_entity)
	spawned_entity.tree_exiting.connect(func() -> void: spawned_entities.erase(spawned_entity))
	spawned_entities.append(spawned_entity)

func restart_timer() -> void:
	spawn_timer.start(GameManager.get_randomized_value(spawn_rate, randomness))

func get_randomized_spawn_location() -> Vector2:
	var theta: float = randf_range(0, TAU)
	var d: float = sqrt(randf_range(0.0, 1.0)) * radius
	var x: float = global_position.x + d * cos(theta)
	var y: float = global_position.y + d * sin(theta)
	return Vector2(x, y)
