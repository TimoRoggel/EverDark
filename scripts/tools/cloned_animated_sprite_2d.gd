class_name ClonedAnimatedSprite2D extends AnimatedSprite2D

@export var target: AnimatedSprite2D = null

func _ready() -> void:
	sprite_frames = target.sprite_frames
	target.animation_changed.connect(func() -> void: animation = target.animation)

func _physics_process(_delta: float) -> void:
	speed_scale = target.speed_scale
	flip_h = target.flip_h
	if target.is_playing() && !is_playing():
		play()
	elif !target.is_playing() && is_playing():
		stop()
