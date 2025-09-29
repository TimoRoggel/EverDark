@abstract @icon("res://graphics/node_icons/state.png")
class_name State extends Node
## A base state class that can be implemented of a plethora of functionalities by a [StateMachine].

## To be emitted when the state should be changed.
signal transition(current_state: State, new_state: String)
## Emitted when the state has been entered.
signal state_entered
## Emitted when the state has been exited.
signal state_exited

## Whether this state is active.
var active: bool = false
## A reference to the state machine that is holding this state.
var state_machine: StateMachine = null
## Whether this state freezes input.
var freezes: bool = false

## Base function that is called when the state is initialized. When expanded [method super] should be called.
func initialize() -> void:
	state_machine = get_parent()

## Returns the [StateMachine]'s [CharacterController].
func _controller() -> CharacterController:
	return state_machine.controller

## Emits the [signal transition] signal with the current and new state.
func _transition(new_state: String) -> void:
	transition.emit(self, new_state)

## Base function that is called when the state is entered.
func enter(enter_parameter: Variant = null) -> void:
	state_entered.emit()
	active = true
	_enter(enter_parameter)

## Base function that is called when the state is exited.
func exit(exit_parameter: Variant = null) -> void:
	state_exited.emit()
	active = false
	_enter(exit_parameter)

## Base function that is called every physics update if the state is active.
func update(delta: float) -> void:
	if !active:
		return
	_update(delta)

## Abstract implementation for when the state is entered.
@abstract func _enter(enter_parameter: Variant) -> void

## Abstract implementation for when the state is exited.
@abstract func _exit(exit_parameter: Variant) -> void

## Abstract implementation for every physics update if the state is active.
@abstract func _update(delta: float) -> void
