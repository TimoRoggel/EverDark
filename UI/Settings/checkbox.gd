extends Control 

@onready var check_box: CheckBox = $HBoxContainer/CheckBox

func _ready() -> void:
	if check_box:
		check_box.button_pressed = GameManager.show_controls_overlay
		check_box.toggled.connect(_on_check_box_toggled)

func _on_check_box_toggled(toggled_on: bool) -> void:
		GameManager.set_controls_visibility(toggled_on)
