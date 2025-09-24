@tool
class_name Pickupable extends Node2D

@export var texture: Texture2D = null:
	set(value):
		texture = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var radius: float = 4.0:
	set(value):
		radius = max(0.0001, value)
		if Engine.is_editor_hint():
			queue_redraw()
@export_group("Pickup", "pickup_")
@export var pickup_sound: AudioStream = null
@export var pickup_script: GDScript = null
@export_custom(PROPERTY_HINT_EXPRESSION, "") var pickup_parameter: String = ""

var sprite: Sprite2D = Sprite2D.new()
var area: Area2D = Area2D.new()
var collision: CollisionShape2D = CollisionShape2D.new()
var shape: CircleShape2D = CircleShape2D.new()
var pickup_player: AudioStreamPlayer2D = AudioStreamPlayer2D.new()
var active: bool = true

func _ready() -> void:
	z_as_relative = false
	z_index = 10
	y_sort_enabled = true
	sprite.texture = texture
	add_child(sprite)
	area.body_entered.connect(_on_body_entered)
	add_child(area)
	shape.radius = radius
	collision.shape = shape
	area.add_child(collision)
	pickup_player.stream = pickup_sound
	add_child(pickup_player)

func _on_body_entered(body: Node) -> void:
	if !is_instance_of(body, PlayerController):
		return
	pickup(body)

func pickup(player: PlayerController) -> void:
	if !active:
		return
	pickup_player.play()
	var instance: Runnable = pickup_script.new()
	var param: Expression = Expression.new()
	param.parse(pickup_parameter)
	instance.run({ "player": player }.merged(param.execute()))
	sprite.visible = false
	await pickup_player.finished
	queue_free()

func set_active(timeout: float) -> void:
	active = false
	await Engine.get_main_loop().create_timer(timeout).timeout
	active = true

func _draw() -> void:
	if !Engine.is_editor_hint():
		return
	draw_circle(Vector2.ZERO, radius, Color.AQUA)
	if texture:
		draw_texture(texture, texture.get_size() * -0.5)

func _notification(what: int) -> void:
	if !Engine.is_editor_hint():
		return
	match what:
		NOTIFICATION_ENTER_CANVAS:
			queue_redraw()
		NOTIFICATION_TRANSFORM_CHANGED:
			queue_redraw()
