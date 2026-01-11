class_name GuardianPhaseComponent extends Component

const PHASE_PROGRESS: AudioStream = preload("uid://b5xfne5vw5m7h")
const SFM_ENEMY: PackedScene = preload("uid://f6apyooo2n66")

var animation: AnimationComponent = null
var health: HealthComponent = null
var audio_player: RandomAudioStreamPlayer2D = null
var current_phase: int = 0:
	set(value):
		if current_phase == value:
			return
		current_phase = value
		if value != 1:
			return
		controller.frozen = true
		animation.play("phase")
		var tween: Tween = create_tween()
		tween.tween_property(health, "current_health", health.max_health, 0.5)
		tween.play()
		audio_player.play_randomized()
		await animation.animated_sprite.animation_finished
		for i: int in 4:
			var sfm: EnemyController = SFM_ENEMY.instantiate()
			var offset: Vector2 = Vector2([0.0, 1.0, 0.0, -1.0][i], [1.0, 0.0, -1.0, 0.0][i])
			offset *= 32.0
			controller.add_sibling(sfm)
			sfm.global_position = global_position + offset
		controller.frozen = false

func _enter() -> void:
	animation = controller.get_component(AnimationComponent)
	health = controller.get_component(HealthComponent)
	audio_player = GameManager.create_audio_player(&"SFX", [PHASE_PROGRESS], self)

func _update(_delta: float) -> void:
	if current_phase != 0:
		return
	if health.current_health < health.max_health * 0.5:
		current_phase += 1

func _exit() -> void:
	pass
