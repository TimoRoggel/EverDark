class_name DeathComponent extends Component

@export_category("Death properties")
@export var can_respawn := false
@export var respawn_point := Vector2.ZERO

var entity: CharacterController
var inventory: InventoryComponent

func _enter():
	entity = controller

func _update(_delta: float) -> void:
	pass
	
func _exit() -> void:
	pass

func entity_died():
	# resetting health right away, otherwise an loop will be caused
	entity.health.reset()
	inventory = controller.inventory
	print("inventory exists: " + str(inventory))
	if inventory:
		inventory.drop_all()
	if controller.hotbar:
		controller.hotbar.update_hotbar()
	# display screen respawn or menu?
	# ref menu later
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
	controller.hitbox.is_active = true
	entity.show()
