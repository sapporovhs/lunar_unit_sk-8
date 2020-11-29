extends StaticBody2D

var damage = 100

func _on_EventArea_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage,true)
