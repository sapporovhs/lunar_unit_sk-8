extends Area2D

const MAX_SCALE = 4.0

var damage = 1
var grow_speed = 5

func _ready():
	Audio.play_moon_wave_sfx()

func _physics_process(delta):
	scale += Vector2.ONE * delta * grow_speed
	modulate = Color(1.0,1.0,1.0,1.0/scale.y/scale.x)
	if scale.y > MAX_SCALE:
		queue_free()
	
func _on_MoonBullet_body_entered(body):
	if body.name == "Player":
		body.take_damage(damage,true)
	Audio.play_collision_sfx()
