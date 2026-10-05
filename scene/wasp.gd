extends CharacterBody2D

@export var speed := 60.0
@export var patrol_distance := 150.0
@export var health := 3

var start_x: float
var dir := 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox: Area2D = $Hitbox


func _ready() -> void:
	start_x = global_position.x
	sprite.play("walk")
	hitbox.body_entered.connect(_on_hitbox_body_entered)


func _physics_process(_delta: float) -> void:
	velocity.x = dir * speed
	# gentle hover bob
	velocity.y = sin(Time.get_ticks_msec() / 300.0) * 20.0
	move_and_slide()

	if absf(global_position.x - start_x) > patrol_distance or is_on_wall():
		dir *= -1
		sprite.flip_h = dir < 0   # flip to (dir > 0) if the art faces the other way


func _on_hitbox_body_entered(body: Node) -> void:
	if body.has_method("take_damage"):
		body.take_damage(1)


func take_damage(amount: int = 1) -> void:
	health -= amount
	sprite.modulate = Color.RED
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color.WHITE
	if health <= 0:
		queue_free()
