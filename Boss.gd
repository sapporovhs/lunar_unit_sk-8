extends KinematicBody2D

enum STATE {IDLE, FLOAT, SUMMON, HEAL, SHOOT, SLAM, WAITING}
enum DAMAGE_STATE {VULNERABLE, INVULNERABLE}

var state_labels = ["vulnerable","invulnerable"]

var speed
var motion = Vector2.ZERO
var hp
var max_hp
var damage = 1
var initial_position
var state = STATE.IDLE
var damage_state
onready var player = get_parent().get_parent().get_child(0)
onready var attacks = get_parent().get_parent().get_parent().get_node("Attacks/Enemy")
var bullet_scene = preload("res://MoonBullet.tscn")
var wave_scene = preload("res://MoonWave.tscn")
var minion_scene = preload("res://EasyEnemy.tscn")

var idle_texture = preload("res://png/moon_idle.png")
var slam_texture = preload("res://png/moon_attack.png")

var tick = 0.0
var idle_period = 1.0
var shooting_period = 3.0
var floating_period = 2.0
var slam_period = 2.0
var bullet_spawn_position = Vector2(-64,64)
var center_of_sprite_position = Vector2(0,0)
var bottom_of_sprite_position = Vector2(0,128)
var minion_spawn_positions = [Vector2(-128,-64),Vector2(-128,64)]

onready var death_particles = preload("res://DeathParticles.tscn")

func _ready():
	speed = 115
	max_hp = 15
	hp = max_hp
	initial_position = position

func wait():
	state = STATE.WAITING
	damage_state = DAMAGE_STATE.INVULNERABLE

func release_from_wait():
	if state == STATE.WAITING:
		state = STATE.IDLE
		damage_state = DAMAGE_STATE.VULNERABLE

func take_damage(damage_from):
	if damage_state == DAMAGE_STATE.VULNERABLE:

		hp -= damage_from
		damage_state = DAMAGE_STATE.INVULNERABLE
		$DamageTimer.start()
		update_hp_bar()
	if hp <= 0:
		die()

func die():
	get_parent().get_parent().get_parent().get_node("Camera2D/InGameMenu").scale = get_parent().get_parent().get_parent().get_node("Camera2D").zoom
	get_parent().get_parent().get_parent().get_node("Camera2D/InGameMenu/EndMessage").text = "Mission Success\nThanks for Playing!"
	get_parent().get_parent().get_parent().get_node("Camera2D/InGameMenu").show()
	Audio.stop_all_music()
	Audio.play_win_sfx()
	player.queue_free()
	queue_free()

func update_hp_bar():
	scale = Vector2(hp/float(max_hp),hp/float(max_hp))
	$HPBar/ColorRect.rect_scale.x = hp / float(max_hp)

func bleed():
	Audio.play_boss_hit_sfx()
	var death_particles_scene = death_particles.instance()
	death_particles_scene.position = position + center_of_sprite_position*scale
	death_particles_scene.emitting = true
	get_parent().add_child(death_particles_scene)
	$DamageTween.interpolate_property($Sprite, "modulate",Color("cb889d"), Color(1,1,1), 0.5,Tween.TRANS_EXPO, Tween.EASE_IN)
	$DamageTween.start()
	
func _physics_process(_delta):
	if get_parent().get_parent().get_parent().get_node("Covers").get_child(int(get_parent().name)-1).visible:
		return
	
	$Label.text = state_labels[damage_state]
	match state:
		STATE.WAITING:
			return
		STATE.IDLE:
			if tick == 0:
				$Sprite.texture = idle_texture
				$Sprite.modulate = Color(1,1,1)
				$PositionTween.interpolate_property(self, "position", position, initial_position, 1.0,Tween.TRANS_EXPO, Tween.EASE_IN)
				$PositionTween.start()
			tick += _delta
			if tick > idle_period:
				tick = 0
				state = STATE.FLOAT
				
		STATE.FLOAT:
			if tick == 0:
				damage_state = DAMAGE_STATE.INVULNERABLE
				$PositionTween.interpolate_property($Sprite, "position", $Sprite.position, $Sprite.position+Vector2(0,-128), 1.0,Tween.TRANS_EXPO, Tween.EASE_IN)
				$PositionTween.start()
			tick += _delta
			motion.y += sin(tick*5)
			motion.x -= cos(tick/floating_period)
			if tick > floating_period:
				tick = 0
				state = STATE.SLAM
				
		STATE.SLAM:
			if tick == 0:
				$Sprite.texture = slam_texture
				damage_state = DAMAGE_STATE.VULNERABLE
				$PositionTween.interpolate_property($Sprite, "position", $Sprite.position, $Sprite.position+Vector2(0,128), 0.5,Tween.TRANS_ELASTIC, Tween.EASE_IN)
				$PositionTween.start()
				var wave = wave_scene.instance()
				wave.position = position + bottom_of_sprite_position*scale
				attacks.add_child(wave)	
			tick += _delta
			motion = Vector2.ZERO
			if tick > slam_period:
				tick = 0
				state = STATE.SHOOT
				
		STATE.SHOOT:
			if not $AnimationTween.is_active():
				$AnimationTween.interpolate_property($Sprite, "modulate",Color(1,1,1), Color("e5e6c7"), $ShotTimer.get_wait_time(),Tween.TRANS_EXPO, Tween.EASE_IN)
				$AnimationTween.start()	
			tick += _delta
			if $ShotTimer.time_left == 0:
				$ShotTimer.start()
			if tick > shooting_period:
				tick = 0
				
				var minion
				
				for mi in range(len(minion_spawn_positions)):
					minion = minion_scene.instance()
					minion.position = position + minion_spawn_positions[mi]*scale
					minion.name += str(get_parent().get_child_count())
					get_parent().add_child(minion)
				
				state = STATE.IDLE

	motion = motion.normalized() * speed

	move_and_slide(motion)
	
	if $HitBox.overlaps_area(player.get_node("HitBox")):
		if player.state == STATE.IDLE and not player.is_moving():
			player.take_damage(damage)

func _on_Timer_timeout():
	damage_state = DAMAGE_STATE.VULNERABLE

func _on_ShotTimer_timeout():
	var bullet = bullet_scene.instance()
	Audio.play_moon_bullet_sfx()
	bullet.position = position + bullet_spawn_position*scale
	attacks.add_child(bullet)
