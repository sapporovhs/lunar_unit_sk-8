extends KinematicBody2D

const MAX_HP = 10

enum STATE {IDLE, MOVING, WAITING, DEAD}
enum DAMAGE_STATE {VULNERABLE, INVULNERABLE}
enum DIRECTIONS {L,R,U,D}

onready var current_position = global_position
onready var motion = Vector2.ZERO
onready var speed = 1000
onready var hp = 10
var damage = 1
var direction = DIRECTIONS.R
var state = STATE.IDLE
var damage_state = DAMAGE_STATE.VULNERABLE
onready var damage_tween = $DamageTween
onready var Attacks = get_parent().get_parent().get_node("Attacks/Player")
onready var attack_line = preload("res://AttackLine.tscn")
onready var skate_particles = preload("res://SkateParticles.tscn")
onready var death_particles = preload("res://DeathParticles.tscn")

var center_of_sprite_position = Vector2(32,32)
var start_position = Vector2.ZERO

func _ready():
	$EntranceTween.interpolate_property($AnimatedSprite,"scale",Vector2(0.0,-10.0),Vector2(1.0,1.0),2.0,Tween.TRANS_ELASTIC,Tween.EASE_IN_OUT)
	$EntranceTween.start()
	damage_tween.interpolate_property($AnimatedSprite, "modulate",Color(1,1,1,0), Color(1,1,1,1), 2.0,Tween.TRANS_EXPO, Tween.EASE_IN)
	damage_tween.start()
	
func is_moving():
	return (motion.length() > 0)

func take_damage(damage_from,force = false):
	if state == STATE.MOVING and not force:
		return
	if damage_state == DAMAGE_STATE.VULNERABLE:
		damage_tween.interpolate_property($AnimatedSprite, "modulate",Color(1,0,0), Color(1,1,1), 0.5,Tween.TRANS_EXPO, Tween.EASE_IN)
		damage_tween.start()
		change_hp(-damage_from)
		bleed()
		damage_state = DAMAGE_STATE.INVULNERABLE
		$DamageTimer.start()

func change_hp(amount):
	hp += amount
	hp = clamp(hp,0,MAX_HP)
	update_hp_bar()

func bleed():
	Audio.play_player_hit_sfx()
	var death_particles_scene = death_particles.instance()
	death_particles_scene.position = position + center_of_sprite_position
	death_particles_scene.emitting = true
	get_parent().add_child(death_particles_scene)
	damage_tween.interpolate_property($AnimatedSprite, "modulate",Color(1,0,0), Color(1,1,1), 0.5,Tween.TRANS_EXPO, Tween.EASE_IN)
	damage_tween.start()

func die():
	$AnimatedSprite.hide()
	state = STATE.DEAD
	get_parent().get_parent().get_node("Camera2D/InGameMenu").scale = get_parent().get_parent().get_node("Camera2D").zoom
	get_parent().get_parent().get_node("Camera2D/InGameMenu/EndMessage").text = "Mission Failed!"
	get_parent().get_parent().get_node("Camera2D/InGameMenu").show()
	Audio.stop_all_music()
	Audio.play_player_die_sfx()
	queue_free()

func wait():
	state = STATE.WAITING

func release_from_wait():
	if state == STATE.WAITING:
		state = STATE.IDLE

func start_attack():
	var attack = attack_line.instance()
	attack.damage = damage
	attack.motion = motion / 62
	attack.start_line(global_position)
	Attacks.add_child(attack)
	
func end_attack():
	Attacks.get_child(Attacks.get_child_count()-1).end_line(global_position)
		
func update_hp_bar():
	$HPBar/ColorRect.rect_scale.x = hp / float(MAX_HP)
	$HPBar.show()

func _physics_process(_delta):
	if state == STATE.WAITING:
		return
	if state == STATE.DEAD:
		return
	if state == STATE.IDLE:
		if hp <= 0:
			die()
		if Input.is_action_pressed("ui_up"):
			motion += Vector2(0, -1)
			$AnimatedSprite.play("slide_up")
			$Particles.rotation = PI*3/2
			direction = DIRECTIONS.U
		elif Input.is_action_pressed("ui_down"):
			motion += Vector2(0, 1)
			$AnimatedSprite.play("slide_down")
			$Particles.rotation = PI/2
			direction = DIRECTIONS.D
		elif Input.is_action_pressed("ui_left"):
			motion += Vector2(-1, 0)
			$AnimatedSprite.play("slide_left")
			$Particles.rotation = PI
			direction = DIRECTIONS.L
		elif Input.is_action_pressed("ui_right"):
			motion += Vector2(1, 0)
			$AnimatedSprite.play("slide_right")
			$Particles.rotation = 0
			direction = DIRECTIONS.R
		else:
			match direction:
				DIRECTIONS.L:
					$AnimatedSprite.play("idle_left")
				DIRECTIONS.R:
					$AnimatedSprite.play("idle_right")
				DIRECTIONS.U:
					$AnimatedSprite.play("idle_up")
				DIRECTIONS.D:
					$AnimatedSprite.play("idle_down")
	
	motion = motion.normalized() * speed

	match state:
		STATE.IDLE:
			if is_moving():
				start_position = global_position
				start_attack()
				state = STATE.MOVING
		STATE.MOVING:
			if not is_moving():
				if start_position == global_position:
					Attacks.get_child(Attacks.get_child_count()-1).queue_free()
				else:
					end_attack()
					var skate_particles_scene = skate_particles.instance()
					skate_particles_scene.emitting = true
					$Particles.add_child(skate_particles_scene)
				state = STATE.IDLE
	motion = move_and_slide(motion)

func _on_Timer_timeout():
	$HPBar.hide()
	damage_state = DAMAGE_STATE.VULNERABLE

func _on_HitBox_body_entered(body):
	if state == STATE.MOVING:
		if body.has_method("take_damage"):
			body.take_damage(damage)
