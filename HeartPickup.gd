extends Area2D

var health_bonus = 10

func _on_Node2D_body_entered(body):
	if body.name == "Player":
		body.change_hp(health_bonus)
		Audio.play_heart_pickup_sfx()
		queue_free()
