class_name RandomizedSprite2D extends Sprite2D

@export var textures: Array[Texture2D] = []

func _ready() -> void:
	var randomizer: RandomNumberGenerator = RandomNumberGenerator.new()
	randomizer.seed = Generator.game_seed
	texture = textures[randomizer.randi_range(0, textures.size() - 1)]
