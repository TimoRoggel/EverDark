class_name AnimationComponent extends Component

const ANIMS: Array[String] = [
	"idle",
	"move",
	"attack"
]
const DIRS: Array[String] = [
	"down",
	"up",
	"right"
]
const MOVEMENT_THRESHOLD: float = 4.0

@export var animated_sprite: AnimatedSprite2D = null

var attacking: bool = false
var should_flip: bool = false
var direction: Vector2 = Vector2.ZERO

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	if animated_sprite.animation.begins_with(ANIMS[2]) && animated_sprite.is_playing():
		return
	animated_sprite.flip_h = should_flip
	var suitable_anim: String = get_suitable_animation()
	if suitable_anim != animated_sprite.animation:
		animated_sprite.play(suitable_anim)

func _exit() -> void:
	pass

func direction_suffix() -> String:
	if direction.is_zero_approx():
		return DIRS[0]
	if abs(direction.x) > abs(direction.y):
		return DIRS[2]
	if direction.y < 0.0:
		return DIRS[1]
	return DIRS[0]

func get_suitable_animation() -> String:
	var anim: String = ANIMS[0]
	if attacking:
		anim = ANIMS[2]
	else:
		if abs(controller.get_real_velocity().length()) > MOVEMENT_THRESHOLD:
			anim = ANIMS[1]
	anim += "_" + direction_suffix()
	return anim
