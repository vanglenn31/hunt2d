extends Node2D

@export var wasp_scene: PackedScene
@export var interval := 4.0                 # seconds between spawns
@export var max_wasps := 4                  # alive at once
@export var spread := Vector2(300.0, 60.0)  # random offset around this node (x, y)

var spawned := []


func _ready() -> void:
	var timer := Timer.new()
	timer.wait_time = interval
	timer.autostart = true
	timer.timeout.connect(_spawn)
	add_child(timer)
	_spawn()


func _spawn() -> void:
	spawned = spawned.filter(func(w): return is_instance_valid(w))
	if wasp_scene == null or spawned.size() >= max_wasps:
		return

	var wasp: Node2D = wasp_scene.instantiate()
	get_tree().current_scene.add_child(wasp)
	wasp.global_position = global_position + Vector2(
		randf_range(-spread.x, spread.x),
		randf_range(-spread.y, spread.y))
	wasp.set("start_x", wasp.global_position.x)   # patrol around where it spawned
	spawned.append(wasp)
