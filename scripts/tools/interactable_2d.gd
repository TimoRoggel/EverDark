@tool
class_name Interactable2D extends Area2D

const SHADER: Shader = preload("uid://b0wqu3tlyguu1")

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

signal interactable
signal not_interactable

func _ready() -> void:
	monitoring = true
	material = _create_material()
	collision_layer = 4
	collision_mask = 4
	shape.radius = radius
	collision.shape = shape
	add_child(collision)
	interact_player.stream = interact_sound
	add_child(interact_player)
	instance = interact_script.new()
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)

func merge_param(controller: CharacterController) -> Dictionary:
	var p_exp: Expression = Expression.new()
	p_exp.parse(custom_parameter)
	return { "controller": controller, "self": self }.merged(p_exp.execute())

func can_interact(controller: CharacterController) -> bool:
	if !is_visible_in_tree():
		set_interactable(false)
		return false
	if !active:
		set_interactable(false)
		return false
	var can: bool = instance.can_run(merge_param(controller))
	set_interactable(can)
	return can

func interact(controller: CharacterController) -> void:
	if !active:
		return
	if interact_sound:
		interact_player.play()
	instance.run(merge_param(controller))
	can_interact(controller)

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

func _create_material() -> ShaderMaterial:
	var mat: ShaderMaterial = ShaderMaterial.new()
	mat.shader = SHADER
	return mat

func _on_area_entered(area: Area2D) -> void:
	var component: Node = area.get_parent()
	if !is_instance_of(component, InteractionComponent):
		return
	if !can_interact(component.controller):
		return
	pass

func _on_area_exited(area: Area2D) -> void:
	var component: Node = area.get_parent()
	if !is_instance_of(component, InteractionComponent):
		return
	set_interactable(false)

func set_interactable(toggled: bool) -> void:
	material.set_shader_parameter("highlighted", toggled)
	if toggled:
		interactable.emit()
	else:
		not_interactable.emit()
