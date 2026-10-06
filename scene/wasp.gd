extends CharacterBody2D

@export var speed := 60.0
@export var patrol_distance := 150.0
@export var health := 1                      # kept for the Inspector, but any hit kills it now
@export var animation_name := "walk"         # preferred animation; falls back automatically

const TURN_COOLDOWN := 0.3                   # seconds before it may turn around again

var start_x: float
var dir := 1
var dying := false
var turn_timer := 0.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox
@onready var body_shape: CollisionShape2D = $CollisionShape2D


func _recenter() -> void:
	# The sprite/collision/hitbox in the scenes sit ~260px away from the node's origin,
	# which made spawns land far to the right. Shift them back onto the origin.
	var off := body_shape.position
	if off == Vector2.ZERO:
		return
	sprite.position -= off
	hitbox.position -= off
	body_shape.position = Vector2.ZERO


func _ready() -> void:
	_recenter()
	add_to_group("enemy")                                # so enemies don't hurt each other
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING   # flyer: no floor/ceiling logic
	start_x = global_position.x
	_play_fly_animation()
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _play_fly_animation() -> void:
	var frames := sprite.sprite_frames
	if frames == null:
		return
	# Try the preferred name, then common names, then whatever animation exists.
	for n in [animation_name, "walk", "BirdFlying", "Flying"]:
		if frames.has_animation(n):
			sprite.play(n)
			return
	var names := frames.get_animation_names()
	if names.size() > 0:
		sprite.play(names[0])


func _physics_process(delta: float) -> void:
	turn_timer = maxf(turn_timer - delta, 0.0)

	velocity.x = dir * speed
	# gentle hover bob
	velocity.y = sin(Time.get_ticks_msec() / 300.0) * 20.0
	move_and_slide()

	var too_far := absf(global_position.x - start_x) > patrol_distance
	if turn_timer <= 0.0 and (too_far or is_on_wall()):
		dir *= -1
		turn_timer = TURN_COOLDOWN
		sprite.flip_h = dir < 0   # flip to (dir > 0) if the art faces the other way


func _on_hitbox_body_entered(body: Node) -> void:
	if dying:
		return
	# Never hurt myself or other enemies (this was killing birds as soon as they met).
	if body == self or body.is_in_group("enemy"):
		return
	if body.has_method("take_damage"):
		body.take_damage(1)


# One hit from an arrow (or anything) kills it.
func take_damage(_amount: int = 1) -> void:
	if dying:
		return
	dying = true
	Game.enemy_hit.emit()
	health = 0
	print("Enemy killed: ", name)
	set_physics_process(false)
	# Collision changes must be deferred because this is called from a physics callback.
	hitbox.set_deferred("monitoring", false)
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	queue_free()
