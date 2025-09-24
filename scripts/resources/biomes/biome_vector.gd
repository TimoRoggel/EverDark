class_name BiomeVector extends Resource

@export_range(-1.0, 2.0, 0.0001) var temperature: float = 0.5
@export_range(-1.0, 2.0, 0.0001) var humidity: float = 0.5
@export_range(-1.0, 2.0, 0.0001) var height: float = 0.5
@export_range(-1.0, 2.0, 0.0001) var fertility: float = 0.5
@export_range(-1.0, 2.0, 0.0001) var weirdness: float = 0.5

func _init(_temperature: float = 0.5, _humidity: float = 0.5, _height: float = 0.5, _fertility: float = 0.5, _weirdness: float = 0.5) -> void:
	temperature = _temperature
	humidity = _humidity
	height = _height
	fertility = _fertility
	weirdness = _weirdness

func distance_to(other: BiomeVector) -> float:
	var distance: float = 0.0
	distance += pow(temperature - other.temperature, 2.0)
	distance += pow(humidity - other.humidity, 2.0)
	distance += pow(height - other.height, 2.0)
	distance += pow(fertility - other.fertility, 2.0)
	distance += pow(weirdness - other.weirdness, 2.0)
	return distance
