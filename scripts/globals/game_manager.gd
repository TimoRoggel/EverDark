extends Node

const OBJECTIVE_DESCRIPTIONS: PackedStringArray = [
	"\"Bring back the light\" by healing the monolith",
	"Throw a VOID Core in the hole",
	"Gather sticks and stone",
	"Kill a monster",
	"Make a stone tool at the crafting bench",
	"Use a torch",
	"Cook a berry or mushroom",
	"Use WASD to move",
	"Use E to open your inventory",
]
const OBJECTIVE_ORDER: PackedInt32Array = [7,8,1,2,3,6,4,5,0]

var stored_values: Dictionary[Node, Variant] = {}
var fetched_types: Dictionary[Variant, Array] = {}
var slowdown_timer: int = 0
var main_camera_component: CameraComponent = null
var player: PlayerController = null
var ui_opened_conditions: Dictionary[String, Callable] = {}
var paused : bool = false
var ui_open : bool = false
var objectives_done: int = 0
var current_objective: int = 0
var is_chest_open : bool = false
var is_player_nearby_hole := false

signal ending
signal objective_finished

func _process(_delta: float) -> void:
	if slowdown_timer <= Time.get_ticks_msec():
		Engine.time_scale = 1.0

func slowdown(amount: float, duration_ms: int) -> void:
	if slowdown_timer > 0 && Engine.time_scale < amount:
		return
	Engine.time_scale = amount
	slowdown_timer = Time.get_ticks_msec() + duration_ms

func update_property_on_all_of_type(type: Variant, property: StringName, value: Variant = null) -> void:
	run_on_all_of_type(type, func(t) -> void: t.set(property, value))

func load_property_on_all_of_type(type: Variant, property: StringName) -> void:
	run_on_all_of_type(type, func(t) -> void: 
		if stored_values.has(t):
			t.set(property, stored_values[t])
	)

func store_property_on_all_of_type(type: Variant, property: StringName) -> void:
	run_on_all_of_type(type, func(t) -> void: stored_values[t] = t.get(property))

func run_on_all_of_type(type: Variant, method: Callable) -> void:
	for t: Variant in get_all_of_type(type):
		method.call(t)

func get_all_of_type(type: Variant, parent: Node = get_tree().root, top_level: bool = true) -> Array:
	if top_level && fetched_types.has(type):
		return fetched_types[type]
	var ret: Array = []
	for child: Node in parent.get_children():
		if is_instance_of(child, type):
			ret.append(child)
		ret.append_array(get_all_of_type(type, child, false))
	if top_level:
		fetched_types[type] = ret
	return ret

func create_audio_player(bus: StringName, samples: Array[AudioStream], parent: Node = null) -> RandomAudioStreamPlayer2D:
	if samples.is_empty():
		return null
	var audio_player: RandomAudioStreamPlayer2D = RandomAudioStreamPlayer2D.new()
	audio_player.attenuation = 6.0
	audio_player.max_distance = 512.0
	audio_player.panning_strength = 2.0
	audio_player.samples = samples
	audio_player.bus = bus
	if parent:
		parent.add_child(audio_player)
	return audio_player

func create_audio_player_basic(bus: StringName, stream: AudioStream, volume_linear: float = 1.0, parent: Node = null) -> AudioStreamPlayer:
	var audio_player: AudioStreamPlayer = AudioStreamPlayer.new()
	audio_player.stream = stream
	audio_player.volume_linear = volume_linear
	audio_player.bus = bus
	audio_player.max_polyphony = 4
	if parent:
		parent.add_child(audio_player)
	return audio_player

func get_randomized_value(input: float, randomness: float) -> float:
	var rand: float = input * randomness
	return randf_range(input - rand, input + rand)

func randv_range(_min: float, _max: float) -> Vector2:
	return Vector2(randf_range(_min, _max), randf_range(_min, _max))

func camera_shake(amount: float, duration: float = 0.1, addative: bool = false) -> void:
	main_camera_component.shake(amount, duration, addative)

func is_ui_open() -> bool:
	for c: Callable in ui_opened_conditions.values():
		if !c.is_valid():
			continue
		if c.is_null():
			continue
		if c.get_object() == null:
			continue
		if c.call():
			return true
	return false

var active_ui_node: Node = null

func set_active_ui(node: Node) -> void:
	active_ui_node = node
	ui_open = true

func clear_active_ui() -> void:
	active_ui_node = null
	ui_open = is_ui_open()

func try_close_active_ui() -> bool:
	if active_ui_node != null and is_instance_valid(active_ui_node):
		if active_ui_node.has_method("close"):
			active_ui_node.close()
		else:
			active_ui_node.visible = false
			clear_active_ui()
		return true
	return false

var show_controls_overlay: bool = true

signal controls_visibility_changed(is_visible: bool)

func set_controls_visibility(value: bool) -> void:
	show_controls_overlay = value
	controls_visibility_changed.emit(show_controls_overlay)

func set_objectives(val: int) -> void: 
	objectives_done = val
	
	var index: int = 0
	for i: int in OBJECTIVE_ORDER:
		var byte: int = roundi(pow(2.0, float(i)))
		if !(objectives_done & byte == byte):
			current_objective = index
			return
		index += 1
	current_objective = -1

func finish_objective(index: int) -> void:
	var byte: int = roundi(pow(2.0, float(index)))
	if !(objectives_done & byte == byte):
		objectives_done += byte
		var current_index: int = OBJECTIVE_ORDER.find(index)
		if current_objective == current_index:
			objective_finished.emit()
			if current_objective == OBJECTIVE_ORDER.size() - 1:
				current_objective = -1
			else:
				current_objective += 1
				byte = roundi(pow(2.0, float(OBJECTIVE_ORDER[current_objective])))
				while objectives_done & byte == byte:
					byte = roundi(pow(2.0, float(OBJECTIVE_ORDER[current_objective])))
					current_objective += 1
				if current_objective >= OBJECTIVE_ORDER.size():
					current_objective = -1

func end() -> void:
	ending.emit()
