class_name PlayerWalkState extends State
## Handles player walking.

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
	# Move based on desired input.
	_controller().movement.desired_movement = _controller().input.movement
	# If we are no longer moving, change to idle state.
	if _controller().input.movement.length() < 0.1:
		# Change state.
		transition.emit(self, "idle")
