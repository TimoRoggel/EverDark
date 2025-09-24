class_name OneShotParticles extends GPUParticles2D

func _ready() -> void:
	restart()
	emitting = true
	finished.connect(func() -> void: queue_free())
