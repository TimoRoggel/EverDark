extends Control

func _draw() -> void:
	for line: Dictionary in Debug.lines.values():
		draw_line(line["from"], line["to"], line["color"], line["width"])

func _process(_delta: float) -> void:
	queue_redraw()
