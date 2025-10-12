class_name EverdarkDamageComponent extends Component

var is_player_pos_reset := false
var curr_tile: TileData

@export var max_virus: float = 100.0
@export var persistent: bool = false

var virusbar_delta_timer: Timer = null

var total_time := 3.0  # total duration in seconds
var elapsed_time := 0.0

var virus_timer: Timer = null

func _enter():
	create_virus_timer()
	pass

func _update(_delta: float) -> void:
	reset_player()
	if Generator.layer:
		if curr_tile != controller.get_tile():
			print("tile: "+ str(controller.get_tile()==null))
			if controller.get_tile()==null:
				controller.hud.virus_bar.activate(self)
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
	controller.hud.virus_bar.min_value = 0
	controller.hud.virus_bar.value = controller.hud.virus_bar.value
	controller.hud.virus_bar.max_value = total_time
	virus_timer = Timer.new()
	virus_timer.autostart = true
	virus_timer.one_shot = false
	virus_timer.wait_time = .1
	virus_timer.timeout.connect(on_virus_timer_timeout)
	controller.hud.add_child(virus_timer)
	
func on_virus_timer_timeout():
	if curr_tile == null:
		elapsed_time += virus_timer.wait_time
	else:
		elapsed_time -= virus_timer.wait_time
	controller.hud.virus_bar.value = elapsed_time

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
		controller.hud.virus_bar.deactivate()
