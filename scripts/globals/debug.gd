extends Node2D

const CENTER: Vector2 = Vector2(320.0, 180.0)

var lines: Dictionary[String, Dictionary] = {}
var position_taker: Node2D = null

func _ready() -> void:
	position_taker = Node2D.new()
	get_tree().current_scene.add_child(position_taker)
	z_index = 999

func _process(delta: float) -> void:
	lines = process_dictionary(lines, delta)
	if GameManager.player:
		global_position = GameManager.player.camera.global_position
	queue_redraw()

func _draw() -> void:
	for line: Dictionary in lines.values():
		draw_line(line["from"], line["to"], line["color"], line["width"])

func add_line(key: String, from: Vector2, to: Vector2, color: Color, duration: float = 0.1, width: float = -1.0, is_screen: bool = false) -> void:
	if !is_screen:
		from = to_screen(from)
		to = to_screen(to)
	lines[key] = {
		"from": from,
		"to": to,
		"color": color,
		"duration": duration,
		"width": width
	}

func process_dictionary(old: Dictionary[String, Dictionary], delta: float) -> Dictionary[String, Dictionary]:
	var new: Dictionary[String, Dictionary] = {}
	for key: String in old.keys():
		var value: Dictionary = old[key]
		var new_duration: float = value["duration"] - delta
		if new_duration > 0.0:
			value["duration"] = new_duration
			new[key] = value
	return new

func to_screen(pos: Vector2) -> Vector2:
	var camera: Camera2D = get_viewport().get_camera_2d()
	return (pos - camera.global_position) * camera.zoom + get_viewport().get_visible_rect().size / 2.0
