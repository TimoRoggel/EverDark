extends Node2D

func _on_area_2d_area_entered(area: Area2D) -> void:
	if is_instance_of(area, DroppedItem2D) && area.item.id == 1:
		area.item = DataManager.get_resource_by_id("items", 0)
