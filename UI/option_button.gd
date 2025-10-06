extends OptionButton


func _on_item_selected(index: int) -> void:
	match index: 
		0: 
			DisplayServer.window_set_size(Vector2i(1920,1080))
		1: 
			DisplayServer.window_set_size(Vector2i(1600,900))
		2: 
			DisplayServer.window_set_size(Vector2i(1280,720))
		3: 
			DisplayServer.window_set_size(Vector2i(640,360))
