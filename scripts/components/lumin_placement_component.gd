class_name LuminPlacementComponent extends Component

const MIN_DISTANCE_TILES: float = 5.0
const TILE_SIZE: float = 16.0
const MIN_DISTANCE: float = (MIN_DISTANCE_TILES * TILE_SIZE) ** 2.0

var current_lumin_positions: PackedVector2Array = []
var input: InputComponent = null
var inventory: InventoryComponent = null
var place_player: RandomAudioStreamPlayer2D = null

@export var lumin_preview_scene: PackedScene
var lumin_preview_instance: CanvasLayer = null
var lumin_sprite: Sprite2D = null 

func _enter() -> void:
	input = controller.get_component(InputComponent)
	input.position_pressed.connect(place)
	inventory = controller.get_component(InventoryComponent)
	place_player = GameManager.create_audio_player(&"SFX", [preload("uid://dr6sn17qunu")], self)

	if lumin_preview_scene:
		lumin_preview_instance = lumin_preview_scene.instantiate() as CanvasLayer
		add_child(lumin_preview_instance)
		
		# Get the Sprite2D inside the CanvasLayer
		lumin_sprite = lumin_preview_instance.get_node("Sprite2D") as Sprite2D
		lumin_sprite.modulate.a = 0.75
		lumin_sprite.visible = false

func _update(_delta: float) -> void:
	if not lumin_sprite:
		return
	var mouse_pos = get_global_mouse_position()
	lumin_sprite.global_position = mouse_pos
	lumin_sprite.visible = inventory.get_held_item_id() == 0

func _exit() -> void:
	if lumin_preview_instance:
		lumin_preview_instance.queue_free()

func place(at: Vector2) -> void:
	if inventory.get_held_item_id() != 0:
		return
	for coords: Vector2 in current_lumin_positions:
		if coords.distance_squared_to(at) < MIN_DISTANCE:
			return
	place_player.global_position = at
	place_player.play_randomized()
	Generator.lumin_positions.append(at)
	current_lumin_positions.append(at)
	inventory.remove(0)
