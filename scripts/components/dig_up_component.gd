class_name DigUpComponent extends Component

const DIG_UP: AudioStream = preload("uid://bn8tq1kgs03wp")

var target: TargetComponent = null
var animation: AnimationComponent = null
var dig_up_player: RandomAudioStreamPlayer2D = null

func _enter() -> void:
	dig_up_player = GameManager.create_audio_player(&"SFX", [DIG_UP], self)
	target = controller.get_component(TargetComponent)
	animation = controller.get_component(AnimationComponent)
	controller.visible = false

func _update(_delta: float) -> void:
	if controller.health.current_health <= 0.0:
		return
	if controller.visible:
		return
	if !target.target:
		return
	if global_position.distance_to(target.target.global_position) > 128.0:
		return
	controller.frozen = true
	controller.visible = true
	dig_up_player.play_randomized()
	animation.play("dig_up")
	await animation.animated_sprite.animation_finished
	controller.frozen = false

func _exit() -> void:
	pass
