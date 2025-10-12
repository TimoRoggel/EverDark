class_name InputComponent2 extends Component

signal ui
signal pickup
signal place(pos: Vector2)

func _init() -> void:
	updates_in_physics = false

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	if Input.is_action_just_pressed("ui"):
		ui.emit()
	if Input.is_action_just_pressed("pickup"):
		pickup.emit()
	if Input.is_action_just_pressed("place"):
		place.emit(get_global_mouse_position())

func _exit() -> void:
	pass
