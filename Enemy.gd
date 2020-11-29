extends KinematicBody2D

enum STATE {IDLE, MOVING, DEAD}
enum DAMAGE_STATE {VULNERABLE, INVULNERABLE}

onready var speed = 0
onready var motion = Vector2.ZERO
onready var hp = 1
onready var max_hp = 1
onready var damage = 1
onready var state = STATE.IDLE
onready var damage_state = DAMAGE_STATE.VULNERABLE
onready var damage_tween = $DamageTween
onready var animation_tween
onready var player = get_parent().get_parent().get_child(0)

onready var up_texture = load("res://png/easy_enemy_back.png")
onready var down_texture = load("res://png/easy_enemy_front.png")
onready var death_particles = preload("res://DeathParticles.tscn")

var tick = 0.0
var random_factor = randf()

var center_of_sprite_position = Vector2(32,32)

func _ready():
	if name[0] == "E":
		speed = 100
		max_hp = 2
	elif name[0] == "M":
		speed = 300
		max_hp = 3
	elif name[0] == "H":
		speed = 1000
		max_hp = 4
		animation_tween = $AnimationTween
	hp = max_hp

func take_damage(damage_from):
	if damage_state == DAMAGE_STATE.VULNERABLE:
		bleed()
		hp -= damage_from
		hp = max(hp,0)
		damage_state = DAMAGE_STATE.INVULNERABLE
		$DamageTimer.start()
#		$HPBar.show()
		update_hp_bar()
		if hp == 0:
			state = STATE.DEAD

func bleed():
	Audio.play_enemy_hit_sfx()
	var death_particles_scene = death_particles.instance()
	death_particles_scene.position = position + center_of_sprite_position
	death_particles_scene.emitting = true
	get_parent().add_child(death_particles_scene)
	damage_tween.interpolate_property($Sprite, "modulate",Color(1,0,0), Color(1,1,1), 0.5,Tween.TRANS_EXPO, Tween.EASE_IN)
	damage_tween.start()

func update_hp_bar():
	$HPBar/ColorRect.rect_scale.x = hp / float(max_hp)

func _physics_process(_delta):
	if get_parent().get_parent().get_parent().get_node("Covers").get_child(int(get_parent().name)-1).visible:
		return
	if state == STATE.DEAD:
		return
	if name[0] == "E":
		motion = player.global_position - global_position
		if motion.x > 0:
			$Sprite.flip_h = true
		else:
			$Sprite.flip_h = false
		if motion.y > 0:
			$Sprite.texture = down_texture
		else:
			$Sprite.texture = up_texture
	elif name[0] == "M":
		tick += _delta
		motion += Vector2(200*sin(tick*3*random_factor)*(0.5-random_factor),200*cos(tick*3*random_factor)*(0.5-random_factor))
		motion += (player.global_position - global_position)*0.1
	elif name[0] == "H":
		if tick == 0:
			animation_tween.interpolate_property($Sprite, "modulate",Color(1,1,1), Color(1,0.0,1), 1.0+random_factor,Tween.TRANS_EXPO, Tween.EASE_IN)
			animation_tween.start()			
		tick += _delta
		if tick > 1.0+random_factor:
			Audio.play_hard_enemy_move_sfx()
			motion = player.global_position - global_position
			if abs(motion.x) > abs(motion.y):
				motion = Vector2(motion.x,0)
			else:
				motion = Vector2(0,motion.y)
			motion = motion
			tick = 0
	
	motion = motion.normalized() * speed

	move_and_slide(motion)
	
	if $HitBox.overlaps_area(player.get_node("HitBox")):
		if player.state == STATE.IDLE and not player.is_moving():
			player.take_damage(damage)

func _on_Timer_timeout():
#	$HPBar.hide()
	if state == STATE.DEAD:
		Audio.play_enemy_die_sfx()
		damage_tween.interpolate_property($Sprite, "modulate",Color(1,1,1,1), Color(1,0,0,0), 1.0,Tween.TRANS_EXPO, Tween.EASE_IN)
		damage_tween.start()
		$DeathTimer.start()
		return
	damage_state = DAMAGE_STATE.VULNERABLE

func _on_HitBox_body_entered(body):
	if body.name != name and body.name != "Player":
		Audio.play_collision_sfx()
		
func _on_DeathTimer_timeout():
	queue_free()
