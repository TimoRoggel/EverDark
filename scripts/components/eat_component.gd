class_name EatComponent extends Component

const HEAL: AudioStream = preload("uid://imir4bbndwc1")

var eat_player: RandomAudioStreamPlayer2D = null

func _enter() -> void:
	eat_player = GameManager.create_audio_player(&"SFX", [HEAL], self)
	controller.get_component(InputComponent).position_pressed.connect(func(_pos: Vector2) -> void:
		if !controller.inventory:
			return
		if !controller.health:
			return
		if controller.health.current_health >= controller.health.max_health:
			return
		var selected_item_id: int = controller.inventory.get_held_item_id()
		if selected_item_id < 0:
			return
		var selected_item: Item = DataManager.get_resource_by_id("items", selected_item_id)
		if selected_item.absorbtion <= 0:
			return
		controller.hotbar.substract_item()
		controller.health.heal(selected_item.absorbtion)
		eat_player.play_randomized()
	)
	
func _update(_delta: float) -> void:
	pass
	
func _exit() -> void:
	pass
