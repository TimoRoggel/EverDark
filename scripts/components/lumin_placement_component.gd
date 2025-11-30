class_name LuminPlacementComponent extends Component

const MIN_DISTANCE_TILES: float = 5.0
const TILE_SIZE: float = 16.0
const MIN_DISTANCE: float = (MIN_DISTANCE_TILES * TILE_SIZE) ** 2.0

var current_lumin_positions: PackedVector2Array = []
var input: InputComponent = null
var inventory: InventoryComponent = null
var place_player: RandomAudioStreamPlayer2D = null

func _enter() -> void:
	input = controller.get_component(InputComponent)
	input.position_pressed.connect(place)
	inventory = controller.get_component(InventoryComponent)
	place_player = GameManager.create_audio_player(&"SFX", [preload("uid://dr6sn17qunu")], self)

func _update(_delta: float) -> void:
	pass

func _exit() -> void:
	pass

func place(at: Vector2) -> void:
	if inventory.get_held_item_id() != 0:
		return
	for coords: Vector2 in current_lumin_positions:
		if coords.distance_squared_to(at) < MIN_DISTANCE:
			return
	place_player.global_position = at
	place_player.play_randomized()
	Generator.lumin_positions.append(at)
	Generator.lumin_sizes.append(Generator.LUMIN_SIZE)
	current_lumin_positions.append(at)
	inventory.remove(0)
