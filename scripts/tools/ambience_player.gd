class_name AmbiencePlayer extends AudioStreamPlayer

## How frequent an ambient sound should be played in seconds.
@export_range(0.0, 600.0, 0.0001) var frequency: float = 50.0
## Randomness of the sound playing.
@export_range(0.0, 1.0, 0.0001) var randomness: float = 0.0

var elapsed: float = 0.0
var area: Area2D = null
var enemy_count: int = 0

func _ready() -> void:
	setup_area.call_deferred()

func _physics_process(delta: float) -> void:
	elapsed += delta
	if elapsed < 25.0:
		return
	var current_enemy_count: int = 0
	for c: Node2D in area.get_overlapping_bodies():
		if !is_instance_of(c, EnemyController):
			continue
		current_enemy_count += 1
	if current_enemy_count > enemy_count:
		ambience()
	enemy_count = current_enemy_count

func ambience() -> void:
	play()
	elapsed = 0.0

func setup_area() -> void:
	area = Area2D.new()
	get_parent().add_child(area)
	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = CircleShape2D.new()
	shape.shape.radius = 128.0
	area.add_child(shape)
