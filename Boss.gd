extends KinematicBody2D

var bullet = preload("res://Enemies/BossBullet.tscn")

onready var timer = get_node("Timer")

var target_position = Vector2.ZERO

func _ready():
	pass

func _physics_process(delta):
	look_at(target_position)

func _on_Detection_body_entered(body):
	target_position = body.position
	
	# want to make 3 bullets
	make_bullet(body)

func make_bullet(body):
	var newBullet = bullet.instance()
	add_child(newBullet)
	print("BOP ")
	get_child(3).set_target_direction(body)

func _on_Detection_body_exited(body):
	target_position = Vector2.ZERO
