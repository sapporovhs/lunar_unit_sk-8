extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	Audio.start_music("intro")
	Audio.play_music("intro")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$Warper3.rect_position.x = $Warper3.rect_position.x+delta*200.0
	if $Warper3.rect_position.x > 640:
		$Warper3.rect_position.x = -320
		
func _on_EasyModeButton_pressed():
	Audio.stop_music("intro")
	get_tree().change_scene("res://Dungeon.tscn")

func _on_ShowCreditsButton_pressed():
	if $CreditsPanel.visible:
		$CreditsPanel.hide()
		$ShowCreditsButton.text = "Show Credits"
	else:
		$CreditsPanel.show()
		$ShowCreditsButton.text = "Hide Credits"
		
func _on_HardModeButton_pressed():
	Audio.stop_music("intro")
	Globals.hard_mode = true
	get_tree().change_scene("res://Dungeon.tscn")
