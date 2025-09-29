class_name InputComponent extends Component

var movement: Vector2 = Vector2.ZERO
var attacking: bool = false
var secondary_attacking: bool = false
var angle_to_cursor: float = 0.0
var dashing: bool = false

var can_spawn: bool = true

signal started_attacking
signal inventory_toggled
signal interact

func _init() -> void:
	updates_in_physics = false

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		get_tree().paused = !get_tree().paused
	if Input.is_action_just_pressed("interact"):
		interact.emit()
	if Input.is_action_just_pressed("attack"):
		started_attacking.emit()
		if can_spawn:
			var item: DroppedItem2D = DroppedItem2D.new()
			item.item = DataManager.resources["items"].pick_random()
			controller.add_sibling(item)
			item.global_position = get_global_mouse_position()
	if Input.is_action_just_pressed("toggle_inventory"):
		can_spawn = !can_spawn
		inventory_toggled.emit()
	movement = Input.get_vector("left", "right", "up", "down")
	attacking = Input.is_action_pressed("attack")
	dashing = Input.is_action_pressed("dash")
	secondary_attacking = Input.is_action_pressed("secondary_attack") && !attacking
	angle_to_cursor = get_angle_to(get_global_mouse_position())

func _exit() -> void:
	pass
