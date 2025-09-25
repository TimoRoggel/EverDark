class_name Everdark extends Area2D

const EVERDARK: ParticleProcessMaterial = preload("uid://cpycf136qhhy4")
const TEXTURE: Texture2D = preload("uid://dk1qo2vdxm00y")

@export var size: Vector2 = Vector2.ONE
@export var cost: int = 1
@export var generate_position: Vector2 = Vector2.ZERO

var particles: GPUParticles2D = GPUParticles2D.new()

func _ready() -> void:
	_create_particles()
	var shape: CollisionShape2D = CollisionShape2D.new()
	shape.shape = RectangleShape2D.new()
	shape.shape.size = size
	add_child(shape)
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if is_instance_of(body, PlayerController):
		if body.inventory.has(0, cost):
			body.inventory.remove(0, cost)
			Generator.generate(generate_position)
			queue_free()

func _create_particles() -> void:
	particles.texture = TEXTURE
	particles.amount = roundi(size.x * size.y)
	particles.lifetime = 5.0
	particles.preprocess = 5.0
	particles.process_material = EVERDARK.duplicate()
	particles.process_material.emission_box_extents = Vector3(size.x, size.y, 1.0)
	add_child(particles)
