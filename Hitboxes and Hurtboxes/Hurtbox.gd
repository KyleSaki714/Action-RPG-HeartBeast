extends Area2D

const HITEFFECT = preload("res://Effects/HitEffect.tscn")

func _on_Hurtbox_area_entered(area):
	var effect = HITEFFECT.instance()
	var main = get_tree().current_scene
	main.add_child(effect)
	effect.global_position = global_position - Vector2(0,8)
