extends Node2D

@export var required_lumin_count: int = 3
@export var activated_sprite: Texture2D

var lumin: int = 0
var is_activated: bool = false
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_activated:
		return
	
	if is_instance_of(area, DroppedItem2D) && area.item.id == 0: 
		var needed_lumin = required_lumin_count - lumin
		
		if area.amount >= needed_lumin:
			lumin += needed_lumin
			area.amount -= needed_lumin
			
			if area.amount <= 0:
				area.queue_free()
		else:
			lumin += area.amount
			area.queue_free()
		
		print("aantal lumin: ", lumin, "/", required_lumin_count)
		
		if lumin >= required_lumin_count:
			activate_monolith()

func activate_monolith():
	is_activated = true
	print("monolith activated")
	
	Generator.lumin_positions.append(global_position)
	Generator.lumin_sizes.append(10.0)
	GameManager.finish_objective(0)
	var index: int = Generator.lumin_sizes.size() - 1
	var tween: Tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_SINE)
	tween.tween_method(Generator.set_lumin_size.bind(index), 10.0, 9999.9, 120.0)
	tween.play()
	
	GameManager.end()
	
	if activated_sprite:
		$Sprite2D.texture = activated_sprite
