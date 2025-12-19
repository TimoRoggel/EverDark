extends Control

@onready var option_button: OptionButton = $HBoxContainer/OptionButton

func _ready() -> void:
	option_button.add_item("Easy", GameSettings.Difficulty.EASY)
	option_button.add_item("Normal", GameSettings.Difficulty.NORMAL)
	option_button.add_item("Hard", GameSettings.Difficulty.HARD)

	option_button.select(GameSettings.current_difficulty)
	
	option_button.item_selected.connect(_on_difficulty_selected)

func _on_difficulty_selected(index: int):
	GameSettings.current_difficulty = index
	print("Difficulty set to:", GameSettings.current_difficulty)
	print("Settings:", GameSettings.difficulty_settings[GameSettings.current_difficulty])
