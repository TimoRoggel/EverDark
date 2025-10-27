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

signal virus_effect(value: float)
signal everdark_entered(yes: bool)
signal virusbar_setup(min)

var curr_tile: TileData
var virus_timer: Timer = null
var elapsed_time := 0.0

func _enter() -> void:
	pass

func _update(_delta: float) -> void:
	if Generator.layer and controller.death:
		if curr_tile != controller.get_tile() and !controller.death.is_dead:
			if controller.get_tile()==null:
				everdark_entered.emit(true)
				virus_timer.start()
			if controller.get_tile() and elapsed_time >= total_time:
				virus_timer.start()
			curr_tile = controller.get_tile()
	
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
	if curr_tile == null:
		elapsed_time += virus_timer.wait_time
	else:
		elapsed_time -= virus_timer.wait_time
	virus_effect.emit(elapsed_time)

	# damage player if virusbar is full
	if elapsed_time >= total_time:
		virus_timer.stop()
		if controller.health:
			var just_hurt = false
			while (curr_tile == null and !controller.death.is_dead): # blijft wws doorgaan na dood gaan
				if not just_hurt:
					controller.health.apply_environmental_damage(self)
					just_hurt = true
				await get_tree().create_timer(1.0).timeout
				just_hurt = false
		else: print("No health component attached!")
		
	# hide virusbar if virusbar reaches zero
	if elapsed_time <= 0.0:
		virus_timer.stop()
		everdark_entered.emit(false)
