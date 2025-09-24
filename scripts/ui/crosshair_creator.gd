class_name CrosshairCreator extends Control

#const CURSOR_DRAWING: CompressedTexture2D = preload("res://graphics/ui/cursor_drawing.png")
#const CURSOR_DRAWING_ERASOR: CompressedTexture2D = preload("res://graphics/ui/cursor_drawing_erasor.png")

@onready var crosshair_selector: OptionButton = %crosshair_selector
@onready var remove: Button = %remove
@onready var crosshair_name: LineEdit = %crosshair_name
@onready var draw_zone: ColorRect = %draw_zone
@onready var drawn_crosshair: TextureRect = %drawn_crosshair
@onready var cursor: TextureRect = %cursor
@onready var cursor_outline: TextureRect = %cursor_outline

var inside_draw_area: bool = false
var selected_color: int = 1
var crosshair_texture: Image = null

func _ready() -> void:
	on_save_data_loaded()
	_on_crosshair_selector_item_selected(UIManager.selected_crosshair)

func _physics_process(_delta: float) -> void:
	cursor.visible = inside_draw_area && UIManager.selected_crosshair != 0
	if !inside_draw_area:
		return
	#cursor_outline.texture = CURSOR_DRAWING_ERASOR if selected_color == 0 else CURSOR_DRAWING
	cursor.global_position = get_global_mouse_position() - Vector2(0, 8)
	cursor.self_modulate = UIManager.COLORS[selected_color]
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		draw_pixel()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		draw_pixel(0)
		#cursor_outline.texture = CURSOR_DRAWING_ERASOR

func draw_pixel(color: int = selected_color) -> void:
	if UIManager.selected_crosshair == 0:
		return
	var pixel_position: Vector2 = get_pixel_position()
	for i: int in range(2):
		if pixel_position[i] < 0.0 || pixel_position[i] > 7.0:
			return
	crosshair_texture.set_pixel(int(pixel_position.x), int(pixel_position.y), UIManager.COLORS[color])
	drawn_crosshair.texture = ImageTexture.create_from_image(crosshair_texture)
	UIManager.crosshairs[UIManager.selected_crosshair]["data"][UIManager.get_position_index(pixel_position)] = color
	SaveManager.save_data()

func get_pixel_position() -> Vector2:
	return floor(drawn_crosshair.get_local_mouse_position() / drawn_crosshair.size * 8.0)

func find_unique_crosshair_name(base_name: String = "new crosshair", suffix: Callable = func(i: int) -> String: return " (" + str(i) + ")") -> String:
	var cname: String = base_name
	if !crosshair_name_in_use(cname):
		return cname
	var num: int = 1
	while (crosshair_name_in_use(cname)):
		cname = base_name + suffix.call(num)
		num += 1
	return cname

func crosshair_name_in_use(cname: String) -> bool:
	for i: int in range(crosshair_selector.item_count):
		if crosshair_selector.get_item_text(i) == cname:
			return true
	return false

#region signals
func _on_crosshair_selector_item_selected(index: int) -> void:
	drawn_crosshair.texture = ImageTexture.create_from_image(UIManager.get_crosshair_image(index))
	crosshair_texture = drawn_crosshair.texture.get_image()
	UIManager.selected_crosshair = index
	remove.disabled = index == 0
	crosshair_name.editable = index != 0
	crosshair_selector.selected = index
	_on_crosshair_name_text_changed(crosshair_selector.get_item_text(index), false)

func _on_add_pressed() -> void:
	var cname: String = find_unique_crosshair_name()
	crosshair_selector.add_item(cname)
	UIManager.crosshairs.append({"name": cname, "data": {}})
	_on_crosshair_selector_item_selected(crosshair_selector.item_count - 1)
	SaveManager.save_data()

func _on_remove_pressed() -> void:
	crosshair_selector.remove_item(UIManager.selected_crosshair)
	UIManager.crosshairs.remove_at(UIManager.selected_crosshair)
	_on_crosshair_selector_item_selected(UIManager.selected_crosshair - 1)
	SaveManager.save_data()

func _on_crosshair_name_text_changed(new_text: String, check_unique: bool = true) -> void:
	var caret_column: int = crosshair_name.caret_column
	var new_name: String = new_text.to_lower()
	if check_unique:
		new_name = find_unique_crosshair_name(new_name, func(i: int) -> String: return "*".repeat(i))
	crosshair_name.text = new_name
	crosshair_selector.set_item_text(UIManager.selected_crosshair, crosshair_name.text)
	UIManager.crosshairs[UIManager.selected_crosshair]["name"] = new_name
	crosshair_name.caret_column = caret_column
	SaveManager.save_data()

func _on_draw_zone_mouse_entered() -> void:
	inside_draw_area = true
	if visible && UIManager.selected_crosshair != 0:
		Input.mouse_mode = Input.MOUSE_MODE_HIDDEN

func _on_draw_zone_mouse_exited() -> void:
	inside_draw_area = false
	if visible:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _on_color_select_white_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		return
	selected_color = 1

func _on_color_select_yellow_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		return
	selected_color = 2

func _on_color_select_pink_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		return
	selected_color = 3

func _on_color_select_purple_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		return
	selected_color = 4

func _on_color_select_erasor_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		return
	selected_color = 0

func on_save_data_loaded() -> void:
	crosshair_selector.clear()
	for crosshair: Dictionary[String, Variant] in UIManager.crosshairs:
		crosshair_selector.add_item(crosshair["name"])
#endregion
