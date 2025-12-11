class_name EverdarkDamageComponent extends Component

@export_category("Everdark properties")

@export_category("Virus bar")
@export var total_time := 3.0
@export var time_step := .1

@export_category("Damage")
@export var power := 1
@export var shake_amount := 3
@export var shake_duration := .5
@export var shake_addative := .2
@export var cur_invulnerability := .4
@export var slowdown := .5
@export var slowdown_duration_ms := 1
@export var damage_sounds: Array[AudioStream] = []

signal virus_effect(value: float)
signal everdark_entered(yes: bool)
signal virusbar_setup(min)

var virus_timer: Timer = null # counts small time steps and based on those steps health and virsubar are updated
var elapsed_time := 0.0
var damage_player: RandomAudioStreamPlayer2D = null
var health: HealthComponent

func _enter() -> void:
	damage_player = GameManager.create_audio_player(&"SFX", damage_sounds, self)
	await get_tree().create_timer(1.0).timeout
	if controller.health:
		health = controller.health

func _update(_delta: float) -> void:
	if virus_timer:
		if controller.death and controller.death.is_dead:
			if virus_timer:
				virus_timer.stop()
			elapsed_time = 0.0
			return
		var in_everdark: bool = Generator.is_in_everdark(controller.global_position)
		# Start timer on enter everdark
		if in_everdark and virus_timer.is_stopped():
			virus_timer.start()
			everdark_entered.emit(true)

		# stop timer on everdark exit
		elif not in_everdark and not virus_timer.is_stopped():
			virus_timer.stop()
			everdark_entered.emit(false)
	
func _exit() -> void:
	pass

func create_virus_timer() -> void:
	virusbar_setup.emit(total_time)
	
	# create timer
	virus_timer = Timer.new()
	virus_timer.autostart = true
	virus_timer.one_shot = false
	virus_timer.wait_time = time_step
	virus_timer.timeout.connect(on_virus_timer_timeout)
	self.add_child(virus_timer)
	

func on_virus_timer_timeout() -> void:
	var in_everdark: bool = Generator.is_in_everdark(controller.global_position)

	# Adjust virus bar
	if in_everdark:
		elapsed_time = min(elapsed_time + virus_timer.wait_time, total_time)
	else:
		elapsed_time = max(elapsed_time - virus_timer.wait_time, 0.0)
	# Update HUD
	controller.hud.update_virusbar_color(
		Color(0.486, 0.003, 0.993, 1.0),
		elapsed_time / total_time
	)
	virus_effect.emit(elapsed_time)

	# Apply damage when bar is full
	if in_everdark and elapsed_time >= total_time:
		if damage_player:
			damage_player.play_randomized()
		if controller.health:
			controller.health.apply_environmental_damage(self)
		elapsed_time = 0.0  # reset bar after damage
