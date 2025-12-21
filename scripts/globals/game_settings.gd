extends Node

enum Difficulty { EASY, NORMAL, HARD }

var current_difficulty: Difficulty = Difficulty.NORMAL

var difficulty_settings = {
	Difficulty.EASY: {"enemy_health": 4, "sprint_speed": 120, "min_radius": 50, "max_radius": 100},
	Difficulty.NORMAL: {"enemy_health": 10, "sprint_speed": 140, "min_radius": 100, "max_radius": 300},
	Difficulty.HARD: {"enemy_health": 20, "sprint_speed": 200, "min_radius": 300, "max_radius": 500}
}
