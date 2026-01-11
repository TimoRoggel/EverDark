class_name HotbarTextureButton extends TextureButton

var item: Item = null
var index: int = 0
var container: Control = null

func _gui_input(event: InputEvent) -> void:
	if !is_instance_of(event, InputEventMouseButton):
		return
	if !event.pressed:
		return
	if event.button_index != MouseButton.MOUSE_BUTTON_LEFT:
		return
	
	container.lock_slot(index)

func _make_custom_tooltip(_for_text: String) -> Object:
	if !item:
		return null
	var vbox: VBoxContainer = VBoxContainer.new()
	var title_label: Label = Label.new()
	title_label.text = item.display_name
	title_label.label_settings = LabelSettings.new()
	title_label.label_settings.font_size = 24
	vbox.add_child(title_label)
	if !item.description.is_empty():
		vbox.custom_minimum_size.x = 256.0
		var desc_label: Label = Label.new()
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		desc_label.set_text.call_deferred(item.description)
		desc_label.modulate.a = 0.75
		vbox.add_child(desc_label)
	return vbox
