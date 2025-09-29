@tool @icon("res://graphics/node_icons/statemachine.png")
class_name StateMachine extends Node
## A base class for handling [State](s).

## A reference to the state that is currently active. Can be set in the inspector.
@export var current_state: State = null

## A reference to the [CharacterController] to be used by the states. Automatically set in [method initialize].
var controller: CharacterController = null
## Holds all states that are found in the children of this [StateMachine].
var states: Dictionary = {}

## Shows warnings in the inspector if node configuration is wrong.
func _get_configuration_warnings() -> PackedStringArray:
	var warnings = []
	if !is_instance_of(get_parent(), CharacterController):
		warnings.append("Parent of this node needs to be of type CharacterController.")
	return warnings

## Notifications.
func _notification(_what: int) -> void:
	if Engine.is_editor_hint():
		update_configuration_warnings()

## Called when the node is ready.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	initialize()

## Initializes the [StateMachine]. Called in [method _ready]. When extended [method super] should be called.
func initialize() -> void:
	# Set the controller based on the parent node
	controller = get_parent()

	# Get all states from its children
	for child: Node in get_children():
		if is_instance_of(child, State):
			states[child.name] = child
			child.initialize()
			child.transition.connect(on_transition)
	
	# Enter initial state if it exists:
	if current_state:
		current_state.enter()
	
## Called once every physics update.
func _physics_process(delta: float) -> void:
	# Don't do anything if not in-game.
	if Engine.is_editor_hint():
		return
	# Update current state
	if current_state:
		current_state.update(delta)

## Forces a transition to a new state.
func force_transition(to: String, enter_parameter: Variant = null, exit_parameter: Variant = null) -> void:
	on_transition(current_state, to, enter_parameter, exit_parameter)

## Transitions the state to a new state.
func on_transition(called_by: State, to: String, enter_parameter: Variant = null, exit_parameter: Variant = null) -> void:
	# Only allow the current state to transition the state
	if called_by != current_state:
		push_error(name + " > " + called_by.name + " tried to transition but is not the current state!")
		return
	
	# Get the new state by name
	var new_state: State = states.get(to.to_lower())
	if !new_state:
		push_error(name + " > " + to + " does not exist in " + ",".join(PackedStringArray(states.keys())))
		return
	
	# Exit the old state
	if current_state:
		current_state.exit(exit_parameter)
	
	# Enter the new state
	current_state = new_state
	current_state.enter(enter_parameter)
