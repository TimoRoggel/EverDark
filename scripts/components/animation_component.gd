class_name AnimationComponent extends Component

const ANIMS: Array[String] = [
	"idle",
	"walk",
	"charge"
]
const MOVEMENT_THRESHOLD: float = 4.0

@export var animated_sprite: AnimatedSprite2D = null
@export var step_frames: int = 0
@export var idle_sounds: Array[AudioStream] = []
@export var walk_sounds: Array[AudioStream] = []
@export var charge_sounds: Array[AudioStream] = []

var possible_anims: Array[String] = []
var should_flip: bool = false
var charging: bool = false
var audio_players: Dictionary[String, RandomAudioStreamPlayer2D] = {}

func _enter() -> void:
	var anim_sounds: Dictionary[String, Array] = {
		ANIMS[0]: idle_sounds,
		ANIMS[1]: walk_sounds,
		ANIMS[2]: charge_sounds
	}
	possible_anims = ANIMS.filter(func(anim: String) -> bool: return animated_sprite.sprite_frames.get_animation_names().has(anim))
	for possible_anim in possible_anims:
		audio_players[possible_anim] = GameManager.create_audio_player(&"sounds", anim_sounds[possible_anim])
		add_child(audio_players[possible_anim])
	animated_sprite.frame_changed.connect(step_sound)

func _update(delta: float) -> void:
	animated_sprite.flip_h = should_flip
	var suitable_anim: String = get_suitable_animation()
	if suitable_anim != animated_sprite.animation:
		if audio_players.has(suitable_anim) && suitable_anim != ANIMS[1]:
			audio_players[suitable_anim].play_randomized()
		animated_sprite.play(suitable_anim)

func _exit() -> void:
	pass

func step_sound() -> void:
	if walk_sounds.size() < 1:
		return
	if animated_sprite.animation != ANIMS[1]:
		return
	if step_frames < 1:
		return
	if animated_sprite.frame % (step_frames + 1) != 0:
		return
	if audio_players[animated_sprite.animation].playing:
		return
	audio_players[animated_sprite.animation].play_randomized()

func get_suitable_animation() -> String:
	var anim: String = possible_anims[0] if !possible_anims.has(ANIMS[0]) else ANIMS[0]
	if charging && possible_anims.has(ANIMS[2]):
		anim = ANIMS[2]
	elif possible_anims.has(ANIMS[1]):
		if abs(controller.get_real_velocity().length()) > MOVEMENT_THRESHOLD:
			anim = ANIMS[1]
	return anim
