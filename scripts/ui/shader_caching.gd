extends CanvasLayer

@export var particle_scenes: Array[PackedScene] = []
@export var additional_particles: Array[Node] = []

@onready var progress: ProgressBar = %progress

var particle_instances: Array[Node] = []

func _ready() -> void:
	if GameManager.cached_shaders:
		queue_free()
		return
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(progress, "value", 99.9, 2.5)
	tween.play()
	for particle_scene: PackedScene in particle_scenes:
		var particle: Node = particle_scene.instantiate()
		add_child(particle)
		particle.emitting = true
		particle_instances.append(particle)
	for particles: Node in additional_particles:
		particles.emitting = true
		particle_instances.append(particles)
	await tween.finished
	for particles: Node in particle_instances:
		particles.visible = false
	GameManager.cached_shaders = true
	queue_free()
