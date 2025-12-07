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

var virus_timer: Timer = null
var elapsed_time := 0.0
var damage_player: RandomAudioStreamPlayer2D = null
var health: HealthComponent

func _enter() -> void:
	damage_player = GameManager.create_audio_player(&"SFX", damage_sounds, self)
	await get_tree().create_timer(1.0).timeout
	if controller.health:
		health = controller.health

func _update(_delta: float) -> void:
	if controller.death:
		if controller.death.is_dead:
			return
		var in_everdark: bool = Generator.is_in_everdark(controller.global_position)
		if in_everdark && virus_timer.is_stopped():
			everdark_entered.emit(true)
			virus_timer.start()
		if in_everdark && elapsed_time >= total_time:
			virus_timer.start()
			var health_percentage = health.max_health / 100 * health.current_health
			virus_effect.emit(elapsed_time * health_percentage)
	
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
	# increasing or decreasing virusbar based on players postition
	var in_everdark: bool = Generator.is_in_everdark(controller.global_position)
	if in_everdark:
		elapsed_time += virus_timer.wait_time
	else:
		elapsed_time -= virus_timer.wait_time
	var health_percentage = controller.health.max_health / 100 * controller.health.current_health
	virus_effect.emit(elapsed_time * health_percentage)
	controller.hud.update_virusbar_color(Color(0.486, 0.003, 0.993, 1.0), elapsed_time/total_time)

	# damage player if virusbar is full
	if elapsed_time >= total_time:
		virus_timer.stop()
		if controller.health:
			var just_hurt = false
			while (Generator.is_in_everdark(controller.global_position) && !controller.death.is_dead): # blijft wws doorgaan na dood gaan
				if !just_hurt:
					if damage_player:
						damage_player.play_randomized()
					controller.health.apply_environmental_damage(self)
					just_hurt = true
				await get_tree().create_timer(1.0).timeout
				just_hurt = false
		else:
			# No health component attached!
			pass
		
	# hide virusbar if virusbar reaches zero
	if elapsed_time <= 0.0:
		virus_timer.stop()
		everdark_entered.emit(false)
