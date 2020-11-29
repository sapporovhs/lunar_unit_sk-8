extends Node2D

var current_sfx_channel = 0
onready var number_of_sfx_channels = $SFXChannels.get_child_count()

onready var sfx = [
	preload("res://sfx/sfx_player_move.wav"),
	preload("res://sfx/sfx_player_damage.wav"),
	preload("res://sfx/sfx_enemy_damage.wav"),
	preload("res://sfx/sfx_moon_bullet.wav"),
	preload("res://sfx/sfx_moon_wave.wav"),
	preload("res://sfx/sfx_mystery_fail.wav"),
	preload("res://sfx/sfx_mystery_success.wav"),
	preload("res://sfx/sfx_boss_damage.wav"),
	preload("res://sfx/sfx_heartpickup.wav"),
	preload("res://sfx/sfx_win.wav"),
	preload("res://sfx/footstep_carpet_000.ogg"),
	preload("res://sfx/footstep_carpet_001.ogg"),
	preload("res://sfx/footstep_carpet_002.ogg"),
	preload("res://sfx/footstep_carpet_003.ogg"),
	preload("res://sfx/footstep_carpet_004.ogg"),
	preload("res://sfx/impactTin_medium_001.ogg"),
]

onready var music = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func increment_sfx_channel():
	current_sfx_channel = (current_sfx_channel+1)%number_of_sfx_channels

func play_skate_sfx():
	play_sfx(0,-8,0.9+randf()*0.2)

func play_hard_enemy_move_sfx():
	play_sfx(0,-8,0.5+randf()*0.2)

func play_player_hit_sfx():
	play_sfx(1,-8,0.9+randf()*0.2)

func play_enemy_hit_sfx():
	var random_sample_index = 10 + randi()%5
	play_sfx(random_sample_index,-4,0.5+randf()*0.2)

func play_moon_bullet_sfx():
	play_sfx(3,-8,0.9+randf()*0.2)

func play_moon_wave_sfx():
	play_sfx(4,-8,0.9+randf()*0.2)

func play_mystery_sfx(success_flag):
	if success_flag:
		play_sfx(6,-8)
	else:
		play_sfx(5,-8)

func play_boss_hit_sfx():
	play_sfx(7,-8,0.9+randf()*0.2)

func play_heart_pickup_sfx():
	play_sfx(8,-8)

func play_win_sfx():
	play_sfx(9,-5)

func play_collision_sfx():
	var random_sample_index = 10 + randi()%5
	play_sfx(random_sample_index,-24,2.0+randf()*0.2)

func play_message_scroll_sfx():
	play_sfx(15,-11,0.9+randf()*0.1)
	
func play_player_die_sfx():
	play_sfx(1,-8,0.1)
	play_sfx(5,-8,1.0)
	
func play_enemy_die_sfx():
	play_sfx(2,-12,0.2+randf()*0.1)

func play_sfx(i,volume_db=-8,pitch_scale=1.0):
	$SFXChannels.get_child(current_sfx_channel).stream = sfx[i]
	if $SFXChannels.get_child(current_sfx_channel).stream is AudioStreamOGGVorbis:
		$SFXChannels.get_child(current_sfx_channel).stream.loop = false
	else:
		$SFXChannels.get_child(current_sfx_channel).stream.loop_mode = AudioStreamSample.LOOP_DISABLED
	$SFXChannels.get_child(current_sfx_channel).volume_db = volume_db
	$SFXChannels.get_child(current_sfx_channel).pitch_scale = pitch_scale
	$SFXChannels.get_child(current_sfx_channel).play()
	increment_sfx_channel()

func room_sequence(room_name):
	match room_name:
		"1":
			play_music("1")
		"2":
			play_music("2")
		"3":
			play_music("3")
		"4":
			play_music("4")
		"5":
			play_music("5")
		"6":
			start_music("6")
			play_music("6")
		"boss":
			play_music("boss")
			
func play_music(title):
	var music_channel = $MusicChannels.get_node(title)
	if music_channel.volume_db > -20:
		return
	$MusicChannels/OnTween.interpolate_property(music_channel,"volume_db",-80,-12,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
	$MusicChannels/OnTween.start()
	
func start_music(title):
	var music_channel = $MusicChannels.get_node(title)
	music_channel.volume_db = -80
	music_channel.play()

func stop_music(title,force=false):
	var music_channel = $MusicChannels.get_node(title)
	if music_channel is AudioStreamPlayer:
		if force:
			music_channel.playing = false
		else:
			$MusicChannels/OffTween.interpolate_property(music_channel,"volume_db",-12,-80,0.1,Tween.TRANS_LINEAR,Tween.EASE_OUT)
			$MusicChannels/OffTween.start()
		
func stop_all_music():
	for channel in $MusicChannels.get_children():
		stop_music(channel.name,true)
