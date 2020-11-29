extends Control

var read_speed

# Called when the node enters the scene tree for the first time.
func _ready():
	read_speed = 1/float(len($Panel/MessageLabel.text))*50
	rect_scale = get_parent().get_parent().zoom

func set_text(speaker,message):
	match speaker:
		"SK-8":
			$PlayerFace.show()
			$MoonFace.hide()
		"Lunafer":
			$PlayerFace.hide()
			$MoonFace.show()
		"Commander Buhtig":
			$PlayerFace.hide()
			$MoonFace.hide()

	$Panel/SpeakerLabel.text = speaker
	$Panel/MessageLabel.text = message

func _process(delta):
	if visible:
		if $Panel/SpeakerLabel.text == "music":
			Audio.start_music($Panel/MessageLabel.text)
			Audio.play_music($Panel/MessageLabel.text)
			free()
			return
		$Panel/MessageLabel.percent_visible = min($Panel/MessageLabel.percent_visible+delta*read_speed,1)
		
		if $Panel/MessageLabel.percent_visible == 1.0:
			if Input.is_action_pressed("ui_select"):
				queue_free()
		elif $SFXTimer.time_left == 0:
			$SFXTimer.start()

func _on_SFXTimer_timeout():
	Audio.play_message_scroll_sfx()
