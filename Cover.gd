extends Area2D

onready var dungeon = get_parent().get_parent()

func _ready():
	pass

func _on_Node2D_body_entered(body):
	if body.name == "Player":
		dungeon.move_camera(position)
		dungeon.zoom_camera(Vector2(1.0,1.0))
		hide()
		if name == "6":
			dungeon.add_message_box("SK-8","Something terrible is coming. I just know it.")
			dungeon.add_message_box("Commander Buhtig","Hope you get lucky and score some HP!")
			Audio.stop_all_music()
		else:
			Audio.room_sequence(name)

func _on_Node2D_body_exited(body):
	if body.name == "Player":
		show()
