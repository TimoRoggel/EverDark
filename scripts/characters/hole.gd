extends AnimatedSprite2D

@onready var convert_sound: AudioStreamPlayer2D = %convert_sound
@onready var area: Area2D = %area
@onready var convert_particles: CPUParticles2D = %convert_particles

var convert_speed: float = 0.5

func _physics_process(_delta: float) -> void:
	if animation == &"bring_up":
		return

	var has_cores: bool = false
	for a: Area2D in area.get_overlapping_areas():
		if is_instance_of(a, DroppedItem2D) && a.item.id == 1 && a.dropped_by_player:
			has_cores = true

	if !has_cores:
		return
	convert_particles.emitting = true
	play(&"bring_up")
	for a: Area2D in area.get_overlapping_areas():
		_on_area_2d_area_entered(a)

	await get_tree().create_timer(convert_speed, false).timeout
	convert_sound.play()
	GameManager.finish_objective(1)
	await animation_finished
	convert_particles.emitting = false
	play(&"default")

func _on_area_2d_area_entered(a: Area2D) -> void:
	if !is_instance_of(a, DroppedItem2D):
		return

	if !a.dropped_by_player:
		return

	if a.item.id != 1:
		return

	a.visible = false
	a.set_active(convert_speed)
	a.item = DataManager.get_resource_by_id("items", 0)
	await get_tree().create_timer(convert_speed, false).timeout
	if a && !a.is_queued_for_deletion():
		a.visible = true
