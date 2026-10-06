extends Node2D

@export var wasp_scene: PackedScene         # the enemy scene to spawn
@export var interval := 4.0                 # seconds between spawns
@export var max_wasps := 4                  # alive at once
@export var whole_map := true               # true = spawn across the entire level width
@export var spread := Vector2(300.0, 60.0)  # y = height band around this node; x only used if whole_map is off
@export var edge_margin := 48.0             # keep spawns this far from the map's left/right edges
@export var clearance := 24.0               # radius of free space needed at the spawn point
@export var attempts := 30                  # random points to try before skipping this spawn

var spawned := []
var x_min := 0.0
var x_max := 0.0


func _ready() -> void:
	if wasp_scene == null:
		push_warning("Spawner: no scene assigned. Set 'Wasp Scene' in the Inspector.")

	_compute_x_range()

	var timer := Timer.new()
	timer.wait_time = interval
	timer.autostart = true
	timer.timeout.connect(_spawn)
	add_child(timer)

	# Physics space isn't ready on the very first frame, so wait before the first spawn.
	await get_tree().physics_frame
	_spawn()


# Work out the left/right limits of the level from the TileMap's used area.
func _compute_x_range() -> void:
	x_min = global_position.x - spread.x
	x_max = global_position.x + spread.x
	if not whole_map:
		return
	var tm = get_tree().current_scene.find_child("TileMap", true, false)
	if tm == null or not tm.has_method("get_used_rect"):
		return
	var rect: Rect2i = tm.get_used_rect()
	if rect.size == Vector2i.ZERO:
		return
	var a: float = tm.to_global(tm.map_to_local(rect.position)).x
	var b: float = tm.to_global(tm.map_to_local(rect.end)).x
	x_min = minf(a, b) + edge_margin
	x_max = maxf(a, b) - edge_margin


func _spawn() -> void:
	spawned = spawned.filter(func(w): return is_instance_valid(w))
	if wasp_scene == null or spawned.size() >= max_wasps:
		return

	var pos := _find_free_position()
	if pos == Vector2.INF:
		return

	var wasp: Node2D = wasp_scene.instantiate()
	get_tree().current_scene.add_child(wasp)
	wasp.global_position = pos
	wasp.set("start_x", pos.x)   # patrol around where it spawned
	spawned.append(wasp)


# Random point inside the level (x across the map, y within the band) that isn't inside terrain.
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
		var pos := Vector2(
			randf_range(x_min, x_max),
			global_position.y + randf_range(-spread.y, spread.y))
		params.transform = Transform2D(0.0, pos)
		if space.intersect_shape(params, 1).is_empty():
			return pos
	return Vector2.INF
