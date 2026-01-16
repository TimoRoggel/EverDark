class_name EverdarkDamageComponent extends Component

@export_category("Everdark properties")

@export_category("Virus bar")
@export var total_time := 3.0
@export var time_step := 1.0

@export_category("Damage")
@export var power := 1
@export var shake_amount := 3
@export var shake_duration := .5
@export var shake_addative := .2
@export var cur_invulnerability := .4
@export var slowdown := .5
@export var slowdown_duration_ms := 1
@export var damage_sounds: Array[AudioStream] = []

signal everdark_entered(yes: bool)
signal virusbar_setup(min)

var damage_player: RandomAudioStreamPlayer2D = null
var health: HealthComponent
var everdark_progress: float = 0.0
var last_damage_progress: float = -time_step
var time_spent_in_everdark: float = 0.0
var in_everdark_last_frame: bool = false

func _enter() -> void:
	damage_player = GameManager.create_audio_player(&"SFX", damage_sounds, self)
	await get_tree().create_timer(1.0).timeout
	if controller.health:
		health = controller.health
	virusbar_setup.emit(total_time)

func _update(delta: float) -> void:
	if !controller.death:
		return
	if controller.death.is_dead:
		return
	var in_everdark: bool = Generator.is_in_everdark(controller.global_position)
	if in_everdark:
		everdark_progress = min(everdark_progress + delta, total_time)
		if everdark_progress >= total_time:
			time_spent_in_everdark += delta
			everdark_damage()
	else:
		time_spent_in_everdark = 0.0
		last_damage_progress = -time_step
		everdark_progress = max(everdark_progress - delta * 2.0, 0.0)
	if in_everdark_last_frame != in_everdark:
		everdark_entered.emit(in_everdark)
	controller.hud.update_virusbar_color(everdark_progress / total_time)
	in_everdark_last_frame = in_everdark
	
func _exit() -> void:
	pass

func everdark_damage() -> void:
	if time_spent_in_everdark - last_damage_progress < time_step:
		return
	
	last_damage_progress = time_spent_in_everdark
	if damage_player:
		damage_player.play_randomized()
	if controller.health:
		controller.health.apply_environmental_damage(self)
