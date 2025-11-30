extends Node

var stored_values: Dictionary[Node, Variant] = {}
var fetched_types: Dictionary[Variant, Array] = {}
var slowdown_timer: int = 0
var main_camera_component: CameraComponent = null
var player: PlayerController = null
var ui_opened_conditions: Dictionary[String, Callable] = {}
var paused : bool = false
var ui_open : bool = false

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
