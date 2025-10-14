@tool
class_name HarvestableBody2D extends Interactable2D

const HARVESTABLE_RUNNABLE: GDScript = preload("uid://b3b33abitpj2t")

@export var harvestable_id: int = -1
@export var harvestable: Harvestable = null:
	set(value):
		harvestable = value
		update_param()

var recover_timer: Timer = Timer.new()
var sprite: Sprite2D = Sprite2D.new()

func _ready() -> void:
	if Engine.is_editor_hint():
		return
	harvestable = DataManager.get_resource_by_id("harvestables", harvestable_id)
	z_as_relative = false
	y_sort_enabled = true
	add_child(sprite)
	recover_timer.one_shot = true
	add_child(recover_timer)
	recover_timer.timeout.connect(update_texture)
	interact_script = HARVESTABLE_RUNNABLE
	active = true
	update_texture()
	super()

func deplete() -> void:
	recover_timer.start(randi_range(harvestable.min_recover_time, harvestable.max_recover_time))
	update_texture()

func update_texture() -> void:
	sprite.texture = harvestable.ready_texture if !is_depleted() else harvestable.depleted_texture

func update_param() -> void:
	custom_parameter = str("{\"harvestable\": ", harvestable.id, "}")
	update_texture()

func is_depleted() -> bool:
	return !recover_timer.is_stopped()
