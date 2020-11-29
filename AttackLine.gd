extends Node2D

var damage = 1
var motion = Vector2.ZERO
var ended = false
onready var tween = $Tween

func _ready():
	if get_parent().name == "Player":
		$Area2D.collision_layer = 4
		$Area2D.collision_mask = 4
	$Timer2.start()

func _process(delta):
	if not ended:
		$Area2D/CollisionShape2D.shape.b += motion
		$Line2D.set_point_position(1,$Area2D/CollisionShape2D.shape.b)

func start_line(coordinate):
	$Area2D/CollisionShape2D.shape.a = coordinate
	$Area2D/CollisionShape2D.shape.b = coordinate
	$Line2D.add_point(coordinate)
	$Line2D.add_point(coordinate)

func end_line(coordinate):
	ended = true
	$Area2D/CollisionShape2D.shape.b = coordinate
	if $Area2D/CollisionShape2D.shape.a != coordinate:
		$Line2D.set_point_position(1,$Area2D/CollisionShape2D.shape.b)
		Audio.play_skate_sfx()
		tween.interpolate_property(self, "modulate",Color(1,1,1,1), Color(1,1,1,0), 0.1,Tween.TRANS_EXPO, Tween.EASE_IN)
		tween.start()
	$Timer.start()

func _on_Timer_timeout():
	queue_free()

func _on_Area2D_body_entered(body):
	return
	if body.name != "Player":
		if body.has_method("take_damage"):
			body.take_damage(damage)


func _on_Timer2_timeout():
	queue_free()
