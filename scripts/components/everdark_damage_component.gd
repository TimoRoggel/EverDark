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
@export var slowdown_duration_ms := 1.0

signal virus_effect(value: float)
signal everdark_entered(yes: bool)
signal virusbar_setup(min)

var curr_tile: TileData
var virus_timer: Timer = null
var elapsed_time := 0.0

func _enter():
	pass

func _update(_delta: float) -> void:
	if Generator.layer:
		if curr_tile != controller.get_tile():
			if controller.get_tile()==null:
				everdark_entered.emit(true)
				virus_timer.start()
			if controller.get_tile() and elapsed_time >= total_time:
				virus_timer.start()
			curr_tile = controller.get_tile()
	
func _exit() -> void:
	pass
	
func create_virus_timer():
	virusbar_setup.emit(total_time)
	
	# create timer
	virus_timer = Timer.new()
	virus_timer.autostart = true
	virus_timer.one_shot = false
	virus_timer.wait_time = time_step
	virus_timer.timeout.connect(on_virus_timer_timeout)
	self.add_child(virus_timer)
	
func on_virus_timer_timeout():
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
			while (curr_tile == null): # blijft wws doorgaan na dood gaan
				await get_tree().create_timer(1.0).timeout
				controller.health.apply_environmental_damage(self)
		else: print("No health component attached!")
		
	# hide virusbar if virusbar reaches zero
	if elapsed_time <= 0.0:
		virus_timer.stop()
		everdark_entered.emit(false)
