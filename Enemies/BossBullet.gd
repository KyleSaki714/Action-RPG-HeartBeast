extends KinematicBody2D

onready var timer = get_node("Timer")
var velocity = Vector2.ZERO
var target_direction = Vector2.ZERO

func _ready():
	print("ready")
	pass

func _physics_process(delta):
	velocity = (500 * target_direction * delta)
	velocity = move_and_collide(velocity)

func set_target_direction(body):
	var target_vector = global_position.direction_to(body.global_position).normalized()
	# (position.distance_to(body.global_position))
	target_direction = target_vector



func _on_Timer_timeout():
	queue_free()
