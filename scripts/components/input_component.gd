class_name InputComponent extends Component

const TEST_CUTSCENE = preload("uid://dptbamp0ib2ib")

var movement: Vector2 = Vector2.ZERO
var attacking: bool = false
var angle_to_cursor: float = 0.0
var dashing: bool = false
var blocking: bool = false

var can_spawn: bool = true

signal started_attacking
signal inventory_toggled
signal interact
signal position_pressed(pos: Vector2)
signal ui
signal pickup
signal place(pos: Vector2)
signal eat

func _init() -> void:
	updates_in_physics = false

func _enter() -> void:
	pass
	
func is_pickup_pressed() -> bool:
	return Input.is_action_just_pressed("pickup")

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		interact.emit()
	if Input.is_action_just_pressed("attack") && !GameManager.is_ui_open():
		started_attacking.emit()
		position_pressed.emit(get_global_mouse_position())
	if Input.is_action_just_pressed("debug") && false:
		DroppedItem2D.drop(10, 1, get_global_mouse_position())
	if Input.is_action_just_pressed("toggle_inventory"):
		toggle_inventory()
	if Input.is_action_just_pressed("eat"):
		eat.emit()
	if Input.is_action_just_pressed("ui"):
		ui.emit()
	if Input.is_action_just_pressed("pickup"):
		pickup.emit()
	if Input.is_action_just_pressed("place") && !GameManager.is_ui_open():
		place.emit(get_global_mouse_position())
	#if Input.is_action_just_pressed("dash"):
		#LoreSystem.open_screen()
		#CutsceneManager.play(TEST_CUTSCENE)
	movement = Input.get_vector("left", "right", "up", "down")
	attacking = Input.is_action_pressed("attack") && !GameManager.is_ui_open()
	blocking = Input.is_action_pressed("block") && !GameManager.is_ui_open()
	dashing = Input.is_action_pressed("dash")
	angle_to_cursor = get_angle_to(get_global_mouse_position())

func _exit() -> void:
	pass

func toggle_inventory() -> void:
	can_spawn = !can_spawn
	inventory_toggled.emit()
