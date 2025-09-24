extends Node

#const SCORE_PARTICLES: PackedScene = preload("res://scenes/effects/score_particles.tscn")
#const NUMBERS: CompressedTexture2D = preload("res://graphics/ui/numbers.png")

var score: float = 0.0:
	set(value):
		score_changed.emit(score, value)
		score = value
		SaveManager.save_data()

signal score_changed(old: int, new: int)

func spawn_score_particle(new_score: int, position: Vector2) -> void:
	score += new_score
	#var particles: GPUParticles2D = SCORE_PARTICLES.instantiate()
	#particles.global_position = position
	#particles.texture = generate_number_texture(new_score)
	#particles.process_material.scale_min = new_score / 100.0
	#particles.process_material.scale_max = new_score / 100.0
	#get_tree().current_scene.add_child(particles)

func generate_number_texture(number: int) -> ImageTexture:
	var number_text: String = str(number)
	var img: Image = Image.create_empty(number_text.length() * 4, 5, false, Image.FORMAT_RGBA8)
	var pos: int = 0
	for character: String in number_text.split():
		var num: int = int(character)
		#img.blit_rect(NUMBERS.get_image(), Rect2i(num * 8, 0, 3, 5), Vector2i(pos * 4, 0))
		pos += 1
	var tex: ImageTexture = ImageTexture.create_from_image(img)
	UIManager.score_texture = tex
	return tex
