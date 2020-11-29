extends Area2D

var message_pairs = [
	["Lunafer","Hi."],
	["SK-8","What the..."],
	["Lunafer","I am Lunafer."],
	["Lunafer","One million years ago, I was SHOT out of the MOON."],
	["SK-8","That's ridiculous."],
	["Lunafer","I know."],
	["Lunafer","Now I have to kill you."],
	["Lunafer","I'm sorry."],
	["SK-8","I'm not."],
	["Commander Buhtig,","Watch out for the spikes!"],
	["music","boss"]
]
onready var dungeon = get_parent().get_parent()
onready var message_box_scene = preload("res://MessageBox.tscn")

func _ready():
	pass

func _process(_delta):
	pass
#	if not visible and not Audio.get_node("MusicChannels/boss").playing and dungeon.get_node("Camera2D/MessageBoxes").get_child_count() == 0:
#		Audio.start_music("boss")
#		Audio.play_music("boss")
		
	
func add_message_box(speaker,message):
	var message_box = message_box_scene.instance()
	message_box.set_text(speaker,message)
	message_box.visible = false
	dungeon.get_node("Camera2D/MessageBoxes").add_child(message_box)

func _on_Node2D_body_entered(body):
	if body.name == "Player":
		for i in range(7):
			Audio.stop_music(str(i),true)
		dungeon.move_camera(position)
#		get_parent().get_parent().get_node("Attacks").get_child(0).hide()
		dungeon.zoom_camera(Vector2(1.8,1.8))
		hide()
		for message_pair in message_pairs:
			add_message_box(message_pair[0],message_pair[1])
		

func _on_Node2D_body_exited(body):
	if body.name == "Player":
		show()
