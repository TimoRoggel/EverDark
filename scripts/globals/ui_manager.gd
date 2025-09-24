extends Node

const COLORS: Array[Color] = [
	Color.TRANSPARENT,
	Color(0.984314, 0.960784, 0.937255),
	Color(0.94902, 0.827451, 0.670588),
	Color(0.776471, 0.623529, 0.647059),
	Color(0.545098, 0.427451, 0.611765),
]

var pause_menu: PauseMenu = null
var settings_menu: SettingsMenu = null
var paused: bool = true
var score_texture: ImageTexture = null
var crosshairs: Array[Dictionary] = [{}]
var selected_crosshair: int = 0:
	set(value):
		selected_crosshair = value
		SaveManager.save_data()

signal pause_toggled

func _ready() -> void:
	toggle_pause()

func _notification(what: int) -> void:
	if [NOTIFICATION_CRASH, NOTIFICATION_EXIT_TREE, NOTIFICATION_WM_CLOSE_REQUEST].has(what):
		SaveManager.save()

func toggle_pause() -> void:
	SaveManager.save()
	if settings_menu:
		settings_menu.hide()
	if pause_menu:
		if paused:
			pause_menu.resume_sound.play_randomized()
		else:
			pause_menu.pause_sound.play_randomized()
	#Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN if paused else Input.MOUSE_MODE_VISIBLE
	paused = !paused
	get_tree().paused = paused
	if pause_menu:
		pause_menu.visible = paused
	if paused:
		GameManager.stored_values.clear()
		GameManager.store_property_on_all_of_type(GPUParticles2D, "speed_scale")
		GameManager.store_property_on_all_of_type(Camera2D, "position_smoothing_speed")
		GameManager.update_property_on_all_of_type(Timer, "paused", true)
		GameManager.update_property_on_all_of_type(GPUParticles2D, "speed_scale", 0.0)
		GameManager.update_property_on_all_of_type(Camera2D, "position_smoothing_speed", 0.0)
	else:
		GameManager.update_property_on_all_of_type(Timer, "paused", false)
		GameManager.load_property_on_all_of_type(GPUParticles2D, "speed_scale")
		GameManager.load_property_on_all_of_type(Camera2D, "position_smoothing_speed")
		GameManager.stored_values.clear()
	GameManager.fetched_types.clear()
	pause_toggled.emit()

func convert_image(image: Image) -> Dictionary[int, int]:
	var dict: Dictionary[int, int] = {}
	for x: int in range(image.get_width()):
		for y: int in range(image.get_height()):
			var pixel: Color = image.get_pixel(x, y)
			var color_index: int = get_color_index(pixel)
			if color_index > -1:
				dict[get_position_index(Vector2(x, y))] = color_index
	return dict

func get_crosshair_image(index: int) -> Image:
	var crosshair: Image = Image.create_empty(8, 8, false, Image.FORMAT_RGBA8)
	for key: int in crosshairs[index]["data"].keys():
		var pos: Vector2 = get_index_position(key)
		var color: Color = COLORS[crosshairs[index]["data"][key]]
		crosshair.set_pixel(int(floor(pos.x)), int(floor(pos.y)), color)
	return crosshair

func get_color_index(color: Color) -> int:
	for i: int in range(COLORS.size()):
		if COLORS[i].to_html() == color.to_html():
			return i
	return -1

func get_index_position(index: int) -> Vector2:
	return Vector2(index % 8, floor(index / 8.0))

func get_position_index(pos: Vector2) -> int:
	return int(floor(pos.x)) + int(floor(pos.y)) * 8
