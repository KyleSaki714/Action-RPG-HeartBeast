extends KinematicBody2D

const PLAYERHURTSOUND = preload("res://Player/PlayerHurtSound.tscn")

const ACCELERATION = 800
const MAX_SPEED = 100
const ROLL_SPEED = 125
const FRICTION = 650

signal after_death

enum {
	MOVE,
	ROLL,
	ATTACK,
	DEATH
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN
var stats = PlayerStats
var control_state = 0 # 0 keyborad, 1 touch

onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox
onready var hurtbox = $Hurtbox
onready var blinkAnimationPlayer = $BlinkAnimationPlayer
onready var joystick = get_parent().get_parent().get_node("CanvasLayer/TouchControls/Joystick/JoystickButton")
# touchscreen buttons are signaling up
onready var touchControls = get_parent().get_parent().get_node("CanvasLayer/TouchControls")
onready var deathScreen = get_parent().get_parent().get_node("CanvasLayer/DeathScreen")

func _ready():
	randomize()
	stats.connect("no_health", self, "start_death")
	touchControls.visible = false
	animationTree.active = true
	deathScreen.visible = false
	swordHitbox.knockback_vector = roll_vector

func _process(delta):
	match state:
		MOVE: 
			move_state(delta)
		ROLL:
			roll_state(delta)
		ATTACK:
			attack_state(delta)
		DEATH:
			death_state(delta)

func _input(event):
	if event is InputEventScreenTouch:
		control_state = 1
		touchControls.visible = true
		
	if event is InputEventKey:
		control_state = 0
		touchControls.visible = false

func move_state(delta):
	var input_vector = Vector2.ZERO
	#input vector handler
	match control_state:
		0: # keyborat
			
			input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
			input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
			input_vector = input_vector.normalized()
			#print(input_vector)
			
			if Input.is_action_just_pressed("roll"):
				state = ROLL
			
			if Input.is_action_just_pressed("attack"):
				state = ATTACK
		1: # touch
			input_vector = joystick.get_value()
			#print(input_vector)
	
	if input_vector != Vector2.ZERO:
		roll_vector = input_vector
		swordHitbox.knockback_vector = input_vector
		animationTree.set("parameters/Idle/blend_position", input_vector)
		animationTree.set("parameters/Run/blend_position", input_vector)
		animationTree.set("parameters/Attack/blend_position", input_vector)
		animationTree.set("parameters/Roll/blend_position", input_vector)
		animationTree.set("parameters/Knocked/blend_position", input_vector)
		animationState.travel("Run")
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		animationState.travel("Idle")
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	

func roll_state(delta):
	velocity = roll_vector * MAX_SPEED * 1.2
	animationState.travel("Roll")
	move()

func attack_state(delta):
	velocity = velocity * 0.9
	animationState.travel("Attack")
	move()

func death_state(delta):
	animationState.travel("Knocked")
	move()
	#print(velocity)

func move():
	velocity = move_and_slide(velocity)
	#print(velocity)

func roll_animation_finished():
	state = MOVE

func attack_animation_finished():
	state = MOVE

func start_death():
	state = DEATH
	print("ded SJFKDSLFJLSKFJDLSKFJLSFJ")
	velocity = velocity * (roll_vector * -1)
	$Hurtbox._on_Hurtbox_invincibility_started()

func death_animation_finished():
	emit_signal("after_death")
	deathScreen.visible = true
	deathScreen.get_child(0).visible = true
	deathScreen.get_child(1).visible = true
	queue_free()

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage
	hurtbox.start_invincibility(0.5)
	hurtbox.create_hit_effect(area)
	var playerHurtSounds = PLAYERHURTSOUND.instance()
	get_tree().current_scene.add_child(playerHurtSounds)

func _on_Hurtbox_invincibility_started():
	blinkAnimationPlayer.play("Start")

func _on_Hurtbox_invincibility_ended():
	blinkAnimationPlayer.play("Stop")


func _on_BtnAtk_pressed():
	state = ATTACK

func _on_BtnRoll_pressed():
	state = ROLL

