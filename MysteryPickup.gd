extends Area2D

var tick = 0

func _process(delta):
	tick += delta
	$Sprite.scale.x = sin(tick)

func _on_MysteryPickup_body_entered(body):
	if body.name == "Player":
		randomize()
		var success_flag = randi()%3==0
		if success_flag:
			get_parent().get_node("HeartPickup").position.y += 320
			get_parent().get_node("HeartPickup").show()
		Audio.play_mystery_sfx(success_flag)
		get_parent().get_child(4).queue_free()
		get_parent().get_child(5).queue_free()
		get_parent().get_child(6).queue_free()
			
