extends Area2D

var motion = Vector2(-1,randf()-0.5)
var damage = 1
var speed = 10
var rotation_speed = 10

func _ready():
	pass 

func _physics_process(delta):
	rotation += delta * rotation_speed
	
	motion = motion.normalized() * speed
	position += motion
	
func _on_MoonBullet_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage,true)
	Audio.play_collision_sfx()
	queue_free()
