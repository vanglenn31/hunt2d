extends Node2D

@export var wasp_scene: PackedScene         # assign bird.tscn here to spawn birds
@export var interval := 4.0                 # seconds between spawns
@export var max_wasps := 4                  # alive at once
@export var spread := Vector2(300.0, 60.0)  # random offset around this node (x, y)
@export var clearance := 24.0               # radius of free space needed at the spawn point
@export var attempts := 12                  # random points to try before skipping this spawn

var spawned := []


func _ready() -> void:
	if wasp_scene == null:
		push_warning("Spawner: no scene assigned. Set 'Wasp Scene' in the Inspector.")

	var timer := Timer.new()
	timer.wait_time = interval
	timer.autostart = true
	timer.timeout.connect(_spawn)
	add_child(timer)

	# Physics space isn't ready on the very first frame, so wait before the first spawn.
	await get_tree().physics_frame
	_spawn()


func _spawn() -> void:
	spawned = spawned.filter(func(w): return is_instance_valid(w))
	if wasp_scene == null or spawned.size() >= max_wasps:
		return

	var pos := _find_free_position()
	if pos == Vector2.INF:
		print("Spawner: no free spot found near ", global_position, " (move the spawner into open air)")
		return

	var wasp: Node2D = wasp_scene.instantiate()
	get_tree().current_scene.add_child(wasp)
	wasp.global_position = pos
	wasp.set("start_x", pos.x)   # patrol around where it spawned
	spawned.append(wasp)
	print("Spawner: spawned ", wasp.name, " at ", pos)


# Returns a random point near this node that isn't inside terrain, or Vector2.INF if none.
func _find_free_position() -> Vector2:
	var space := get_world_2d().direct_space_state
	var shape := CircleShape2D.new()
	shape.radius = clearance

	var params := PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.collision_mask = 0xFFFFFFFF
	params.collide_with_bodies = true
	params.collide_with_areas = false

	for i in attempts:
		var pos := global_position + Vector2(
			randf_range(-spread.x, spread.x),
			randf_range(-spread.y, spread.y))
		params.transform = Transform2D(0.0, pos)
		if space.intersect_shape(params, 1).is_empty():
			return pos
	return Vector2.INF
