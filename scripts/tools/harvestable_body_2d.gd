@tool
class_name HarvestableBody2D extends Interactable2D

const HARVESTABLE_RUNNABLE: GDScript = preload("res://scripts/tools/runnables/harvestable_runnable.gd")

@export var harvestable_id: int = -1
@export var harvestable: Harvestable = null:
	set(value):
		harvestable = value
		update_param()

var recover_timer: Timer = Timer.new()
var sprite: Sprite2D = Sprite2D.new()
var particles: GPUParticles2D = null

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	harvestable = DataManager.get_resource_by_id("harvestables", harvestable_id)
	z_as_relative = false
	y_sort_enabled = true
	sprite.use_parent_material = true
	add_child(sprite)
	recover_timer.one_shot = true
	add_child(recover_timer)
	recover_timer.timeout.connect(update_texture)
	interact_script = HARVESTABLE_RUNNABLE
	active = true
	update_texture()
	SaveSystem.track(name, get_recover_time, set_recover_time, 0.0)
	super()

func deplete(time: float = randi_range(harvestable.min_recover_time, harvestable.max_recover_time)) -> void:
	recover_timer.start(time)
	if particles:
		particles.restart()
		particles.emitting = true
	update_texture()

func update_texture() -> void:
	sprite.texture = harvestable.ready_texture if !is_depleted() else harvestable.depleted_texture
	if !sprite.texture:
		return
	sprite.centered = false
	sprite.offset.x = -sprite.texture.get_width() / 2.0
	sprite.offset.y = -sprite.texture.get_height()

func update_param() -> void:
	custom_parameter = str("{\"harvestable\": ", harvestable.id, "}")
	if particles:
		particles.queue_free()
	if harvestable.particle_scene:
		particles = harvestable.particle_scene.instantiate()
		add_child(particles)
	update_texture()

func is_depleted() -> bool:
	return !recover_timer.is_stopped()

func get_recover_time() -> float:
	return recover_timer.time_left

func set_recover_time(time: float) -> void:
	if time > 0.0:
		deplete(time)
