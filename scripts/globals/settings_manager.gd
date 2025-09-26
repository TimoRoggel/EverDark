extends Node

func change_volume(bus_idx: int, volume: float) -> void:
	AudioServer.set_bus_volume_db(bus_idx, volume)
