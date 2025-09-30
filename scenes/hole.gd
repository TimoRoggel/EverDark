extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_area_2d_area_entered(area: Area2D) -> void:
	print("I am speed")
	if area.get("item").id == 1:  # Core
		# Convert Core into Lumin
		area.set("item:id", 0)  # Lumin has item_id 0
		print("Core converted to Lumin!")
		 # Replace with function body.
