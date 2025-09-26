class_name InputComponent extends Component

var movement: Vector2 = Vector2.ZERO
var shooting: bool = false
var secondary_shooting: bool = false
var angle_to_cursor: float = 0.0
var dashing: bool = false

var can_spawn: bool = true

signal started_shooting
signal inventory_toggled

func _init() -> void:
	updates_in_physics = false

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	if Input.is_action_just_pressed("shoot"):
		started_shooting.emit()
		if can_spawn:
			var item: ItemPickup2D = ItemPickup2D.new()
			item.item = DataManager.resources["items"].pick_random()
			controller.add_sibling(item)
			item.global_position = get_global_mouse_position()
	if Input.is_action_just_pressed("toggle_inventory"):
		can_spawn = !can_spawn
		inventory_toggled.emit()
	movement = Input.get_vector("left", "right", "up", "down")
	shooting = Input.is_action_pressed("shoot")
	dashing = Input.is_action_pressed("dash")
	secondary_shooting = Input.is_action_pressed("secondary_shoot") && !shooting
	angle_to_cursor = get_angle_to(get_global_mouse_position())

func _exit() -> void:
	pass
