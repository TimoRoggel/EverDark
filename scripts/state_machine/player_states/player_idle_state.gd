class_name PlayerIdleState extends State

## Called when the state is entered.
func _enter(_enter_parameter: Variant = null) -> void:
	pass

## Called when the state is exited.
func _exit(_exit_parameter: Variant = null) -> void:
	pass

## Called every physics update.
func _update(_delta: float) -> void:
	# Don't update if no input is initialized.
	if !_controller().input:
		return
	# If moving transition to walk.
	if _controller().input.movement.length() >= 0.1:
		# Change state.
		_transition("walk")
