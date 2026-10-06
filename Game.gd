extends Node

signal enemy_hit

const MENU := "res://scene/start_menu.tscn"
const LEVELS := [
	"res://scene/primordial.tscn",
	"res://scene/forest.tscn",
	"res://scene/cave.tscn",
]
const TARGETS := [5, 7, 10]   # hits needed per level (same order as LEVELS)
var current_level := 0

func load_level(i: int) -> void:
	get_tree().paused = false          # menus pause the game, so always unpause first
	current_level = i
	get_tree().change_scene_to_file(LEVELS[i])

func is_last_level() -> bool:
	return current_level + 1 >= LEVELS.size()

func next_level() -> void:
	if not is_last_level():
		load_level(current_level + 1)
	else:
		go_to_menu()

func restart_level() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func restart_game() -> void:
	load_level(0)                      # straight back into level 1

func go_to_menu() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file(MENU)
