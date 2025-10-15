class_name DeathComponent extends Component

@export_category("Death properties")
@export var can_respawn := false
@export var respawn_point := Vector2.ZERO

var entity: CharacterController
var inventory: InventoryComponent

func _enter():
	entity = controller
	inventory = controller.inventory

func _update(_delta: float) -> void:
	pass
	
func _exit() -> void:
	pass

func entity_died():
	if inventory:
		#inventory.drop_all()
		print("count" + "items dropped")
	if can_respawn:
		# disable entity here
		controller.hitbox.is_active = false
		entity.hide()
		respawn(respawn_point)
	else:
		entity.queue_free()
		print(entity.name + " died!")
	
func respawn(location: Vector2):
	print(entity.name + " respawning...")
	await get_tree().create_timer(1.5).timeout
	entity.global_position = location
	entity.health.reset()
	controller.hitbox.is_active = true
	entity.show()
