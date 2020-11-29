extends StaticBody2D

onready var actors = get_parent().get_parent().get_parent().get_node("Actors")
onready var tween = $Tween

func _ready():
	pass # Replace with function body.



func _on_EventArea_body_entered(body):
	if body.name == "Player":
		if actors.get_node(name).get_child_count() == 0:
			tween.interpolate_property($Sprite, "scale",Vector2(-1,1), Vector2(0,1), 0.5,Tween.TRANS_LINEAR, Tween.EASE_OUT)
			tween.start()			

func _on_Tween_tween_all_completed():
	$CollisionShape2D.disabled = !$CollisionShape2D.disabled

func _on_EventArea2_body_exited(body):
	if body.name == "Player":
		tween.interpolate_property($Sprite, "scale",Vector2(0,1),Vector2(-1,1), 0.5,Tween.TRANS_LINEAR, Tween.EASE_OUT)
		tween.start()			
