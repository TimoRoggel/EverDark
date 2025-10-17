extends Node2D

@export var required_lumin_count: int = 3
@export var activated_sprite: Texture2D

var lumin: int = 0
var is_activated: bool = false

func _ready():
		$Label.text = "monolith"
	
func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_activated:
		return
	
	if is_instance_of(area, DroppedItem2D) && area.item.id == 0: 
		lumin += 1
		area.queue_free() 
		
		print("aantal lumin: ", lumin, "/", required_lumin_count)
		
		if lumin >= required_lumin_count:
			activate_monolith()

func activate_monolith():
	is_activated = true
	print("monolith activated")
	
	if activated_sprite:
		$Sprite2D.texture = activated_sprite
	
	$Label.text = "monolith activated"
