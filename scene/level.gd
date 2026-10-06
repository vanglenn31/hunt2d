extends Node2D

const EndMenu := preload("res://scene/end_menu.gd")

@export var target_hits := 5        # overridden by Game.TARGETS when this scene is in Game.LEVELS
@export var time_limit := 60.0

var hits := 0
var time_left := 0.0
var active := true

@onready var label: Label = $CanvasLayer/Label

func _ready() -> void:
	var idx: int = Game.LEVELS.find(scene_file_path)
	if idx >= 0:
		Game.current_level = idx
		target_hits = Game.TARGETS[idx]
	time_left = time_limit
	Game.enemy_hit.connect(_on_enemy_hit)
	_update_ui()

func _process(delta: float) -> void:
	if not active:
		return
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_fail()
	_update_ui()

func _on_enemy_hit() -> void:
	if not active:
		return
	hits += 1
	_update_ui()
	if hits >= target_hits:
		_win()

func _update_ui() -> void:
	label.text = "Level %d\nHits: %d / %d\nTime: %d" % [Game.current_level + 1, hits, target_hits, ceili(time_left)]

func _win() -> void:
	active = false
	if Game.is_last_level():
		_show_menu("You beat the game!", [
			["Play Again", Game.restart_game],
			["Main Menu", Game.go_to_menu],
		])
	else:
		_show_menu("Level Complete!", [
			["Next Stage", Game.next_level],
			["Retry Stage", Game.restart_level],
		])

func _fail() -> void:
	active = false
	_show_menu("Time's Up!", [
		["Retry Stage", Game.restart_level],
		["Main Menu", Game.go_to_menu],
	])

func _show_menu(title: String, buttons: Array) -> void:
	var menu := EndMenu.new()
	add_child(menu)
	menu.show_menu(title, buttons)
