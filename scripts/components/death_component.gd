class_name DeathComponent extends Component

@export_category("Death properties")
@export var respawn_point := Vector2.ZERO

var entity: CharacterController
var inventory: InventoryComponent
var animation: AnimationComponent

var is_dead := false

func _enter():
	entity = controller
	animation = controller.get_component(AnimationComponent)

func _update(_delta: float) -> void:
	pass
	
func _exit() -> void:
	pass

func entity_died():
	# resetting health right away, otherwise an loop will be caused
	is_dead = true
	entity.health.reset()
	inventory = controller.inventory
	if inventory:
		inventory.drop_all()
	if controller.hotbar:
		controller.hotbar.update_hotbar()
	controller.hitbox.is_active = false
	controller.set_physics_process(false)
	await animation.play("death")
	entity.target_sprite.hide()
	controller.death_view.show()
	
func respawn():
	controller.death_view.hide()
	print(entity.name + " respawning...")
	await get_tree().create_timer(.5).timeout
	is_dead = false
	entity.global_position = respawn_point
	controller.hitbox.is_active = true
	controller.set_physics_process(true)
	entity.target_sprite.show()
