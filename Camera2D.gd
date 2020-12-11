extends Camera2D

onready var topLeft = $Limits/TopLeft
onready var bottomRight = $Limits/BottomRight

func _ready():
	limit_top = topLeft.position.y
	limit_left = topLeft.position.x
	limit_bottom = bottomRight.position.y
	limit_bottom = bottomRight.position.x

func small_shake():
	$ScreenShake.start(0.1, 15, 4, 0)



func _on_Hitbox_area_entered(area):
	print("shake")
	small_shake()
