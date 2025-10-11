class_name EverdarkDamageComponent extends Component

var is_player_pos_reset := false
var curr_value: TileData

func _enter():
	pass

func _update(_delta: float) -> void:
	reset_player()
	if Generator.layer:
		if curr_value != controller.get_tile():
			print("tile: "+ str(controller.get_tile()==null))
			if controller.get_tile()==null:
				if controller.health:
					controller.health.apply_environmental_damage()
				else: print("No health component attached!")
			curr_value = controller.get_tile()
		
		
func reset_player():
	if !is_player_pos_reset:
		curr_value = controller.get_tile()
		controller.global_position = Vector2.ZERO
		is_player_pos_reset = true
	
func _exit() -> void:
	pass
