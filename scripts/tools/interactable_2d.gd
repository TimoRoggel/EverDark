@tool
class_name Interactable2D extends Area2D

@export var radius: float = 8.0:
	set(value):
		radius = max(0.0001, value)
		if Engine.is_editor_hint():
			queue_redraw()
@export_group("interact", "interact_")
@export var interact_sound: AudioStream = null
@export var interact_script: GDScript = null
@export_custom(PROPERTY_HINT_EXPRESSION, "") var custom_parameter: String = ""

var collision: CollisionShape2D = CollisionShape2D.new()
var shape: CircleShape2D = CircleShape2D.new()
var interact_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
var active: bool = true
var instance: Runnable = null

func _ready() -> void:
	monitoring = false
	collision_layer = 4
	collision_mask = 0
	shape.radius = radius
	collision.shape = shape
	add_child(collision)
	interact_player.stream = interact_sound
	add_child(interact_player)
	instance = interact_script.new()

func merge_param(controller: CharacterController) -> Dictionary:
	var p_exp: Expression = Expression.new()
	p_exp.parse(custom_parameter)
	return { "controller": controller, "self": self }.merged(p_exp.execute())

func can_interact(controller: CharacterController) -> bool:
	if !active:
		return false
	return instance.can_run(merge_param(controller))

func interact(controller: CharacterController) -> void:
	if !active:
		return
	if interact_sound:
		interact_player.play()
	instance.run(merge_param(controller))

func set_active(timeout: float) -> void:
	active = false
	await Engine.get_main_loop().create_timer(timeout).timeout
	active = true

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, radius, Color.AQUA)

func _notification(what: int) -> void:
	if !Engine.is_editor_hint():
		return
	match what:
		NOTIFICATION_ENTER_CANVAS:
			queue_redraw()
		NOTIFICATION_TRANSFORM_CHANGED:
			queue_redraw()
