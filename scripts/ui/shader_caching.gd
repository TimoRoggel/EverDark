extends CanvasLayer

@export var particle_scenes: Array[PackedScene] = []
@export var additional_particles: Array[Node] = []

@onready var progress: ProgressBar = %progress

func _ready() -> void:
	if GameManager.cached_shaders:
		queue_free()
		return
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(progress, "value", 99.9, 5.0)
	tween.play()
	for particle_scene: PackedScene in particle_scenes:
		var particle: Node = particle_scene.instantiate()
		add_child(particle)
		particle.emitting = true
	for particles: Node in additional_particles:
		particles.emitting = true
	await tween.finished
	GameManager.cached_shaders = true
	queue_free()
