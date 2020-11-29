extends Node2D

onready var camera_tween = $Camera2D/Tween
onready var player = get_node("Actors/Player")
onready var boss = get_node("Actors/7/Boss")

var message_pairs = [
	["Commander Buhtig","The presence of evil grows stronger on the MOON."],
	["SK-8","I must skate to the source and destroy it..."],
	["Commander Buhtig","It's a crazy idea... but it's worth a SHOT!"],
]
onready var message_box_scene = preload("res://MessageBox.tscn")

func _ready():
	for message_pair in message_pairs:
		add_message_box(message_pair[0],message_pair[1])
	for i in range(7):
		Audio.start_music(str(i))
	Audio.play_music("0")
	if Globals.hard_mode:
		player.hp = 1

func reset():
	# add player
	# remove all enemies
	# add enemies
	pass

func add_message_box(speaker,message):
	var message_box = message_box_scene.instance()
	message_box.set_text(speaker,message)
	message_box.visible = false
	get_node("Camera2D/MessageBoxes").add_child(message_box)

func move_camera(destination_position):
	camera_tween.interpolate_property($Camera2D, "position",$Camera2D.position, destination_position, 0.5,Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	camera_tween.start()

func zoom_camera(magnification):
	$Camera2D.zoom = magnification

func _process(_delta):
	if get_node("Camera2D/MessageBoxes").get_child_count() > 0:
		for attack in get_node("Attacks/Player").get_children():
			attack.hide()
			attack.ended = true
		var current_message_box = get_node("Camera2D/MessageBoxes").get_child(0)
		if (current_message_box != null) and (not current_message_box.visible):
			player.wait()
			boss.wait()
			current_message_box.show()
		if not $Camera2D/Background.visible:
			$Camera2D/Background.show()
	else:
		if $Camera2D/Background.visible:
			$Camera2D/Background.hide()
		if player:
			player.release_from_wait()
		if boss:
			boss.release_from_wait()

func _on_QuitButton_pressed():
	get_tree().change_scene("res://MainMenu.tscn")
