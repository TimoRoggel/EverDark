@tool
class_name InteractionComponent extends Component

const DEBUG_COLOR: Color = Color(1.0, 0.805, 0.27, 0.502)

const INTERACT_SPRITE_OFFSET: Vector2 = Vector2(0.0, -12.0)

@export var interact_radius: float = 16.0:
	set(value):
		interact_radius = value
		queue_redraw()
@export var interact_texture: Texture2D = null

@export var auto_pickup_wait_time : float = .5

var area: Area2D = Area2D.new()
var shape: CollisionShape2D = CollisionShape2D.new()
var inventory: InventoryComponent = null
var closest_interactable: Interactable2D = null

var interact_sprite: Sprite2D = Sprite2D.new()

func _draw() -> void:
	if Engine.is_editor_hint():
		draw_circle(Vector2.ZERO, interact_radius, DEBUG_COLOR)
		draw_circle(Vector2.ZERO, interact_radius, DEBUG_COLOR, false)

func _enter() -> void:
	if Engine.is_editor_hint():
		return
	interact_sprite.texture = interact_texture
	interact_sprite.top_level = true
	add_child(interact_sprite)
	inventory = controller.get_component(InventoryComponent)
	controller.get_component(InputComponent).interact.connect(_on_interact)
	add_child(area)
	shape.shape = CircleShape2D.new()
	shape.shape.radius = interact_radius
	area.add_child(shape)
	area.collision_mask = 4
	area.collision_layer = 4

func _update(_delta: float) -> void:
	if Engine.is_editor_hint():
		return
	interact_sprite.visible = closest_interactable != null
	if closest_interactable:
		interact_sprite.global_position = closest_interactable.global_position + INTERACT_SPRITE_OFFSET
	var interactables: Array = area.get_overlapping_areas().filter(
		func(n: Area2D) -> bool: 
			return is_instance_of(n, Interactable2D) && n.can_interact(controller)
			)
	if interactables.is_empty():
		closest_interactable = null
		return
	if interactables.size() > 1:
		interactables.sort_custom(
			func(a: Interactable2D, b: Interactable2D) -> bool:
				return a.global_position.distance_squared_to(global_position) < b.global_position.distance_squared_to(global_position)
				)
	if closest_interactable == interactables[0]:
		return
	closest_interactable = interactables[0]
	await get_tree().create_timer(auto_pickup_wait_time).timeout
	if closest_interactable is DroppedItem2D:
		if !inventory.is_full():
			_on_interact()

func _on_interact() -> void:
	if !closest_interactable:
		return
	closest_interactable.interact(controller)

func _exit() -> void:
	pass
