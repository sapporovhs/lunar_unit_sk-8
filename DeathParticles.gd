extends CPUParticles2D

onready var tick = 0
# Called when the node enters the scene tree for the first time.
func _process(delta):
	tick += delta
	if tick > lifetime:
		queue_free()
