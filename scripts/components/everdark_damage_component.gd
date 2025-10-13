class_name EverdarkDamageComponent extends Component

var is_player_pos_reset := false
var curr_tile: TileData

var virusbar_delta_timer: Timer = null

@export var total_time := 3.0
@export var time_step := .1
var elapsed_time := 0.0

var virus_timer: Timer = null

signal virus_effect(value: float)
signal everdark_entered(yes: bool)
signal virusbar_setup(min)

func _enter():
	pass

func _update(_delta: float) -> void:
	reset_player()
	if Generator.layer:
		if curr_tile != controller.get_tile():
			print("tile: "+ str(controller.get_tile()==null))
			if controller.get_tile()==null:
				everdark_entered.emit(true)
				virus_timer.start()
			if controller.get_tile() and elapsed_time >= total_time:
				virus_timer.start()
			curr_tile = controller.get_tile()
		
		
func reset_player():
	if !is_player_pos_reset:
		curr_tile = controller.get_tile()
		controller.global_position = Vector2.ZERO
		is_player_pos_reset = true
	
func _exit() -> void:
	pass
	
func create_virus_timer():
	virusbar_setup.emit(total_time)
	
	virus_timer = Timer.new()
	virus_timer.autostart = true
	virus_timer.one_shot = false
	virus_timer.wait_time = time_step
	virus_timer.timeout.connect(on_virus_timer_timeout)
	self.add_child(virus_timer)
	
func on_virus_timer_timeout():
	if curr_tile == null:
		elapsed_time += virus_timer.wait_time
	else:
		elapsed_time -= virus_timer.wait_time
	virus_effect.emit(elapsed_time)

	if elapsed_time >= total_time:
		virus_timer.stop()
		if controller.health:
			#for i in controller.health.current_health/controller.health.max_health:
				#if (curr_tile == null):
					#break
			while (curr_tile == null): # blijft wws doorgaan na dood gaan
				await get_tree().create_timer(1.0).timeout
				controller.health.apply_environmental_damage()

		else: print("No health component attached!")
	if elapsed_time <= 0.0:
		virus_timer.stop()
		everdark_entered.emit(false)
