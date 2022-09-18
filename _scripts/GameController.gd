extends Node

var slowmo_counter = 0

func _ready():
	pass

func _process(delta):
	if (slowmo_counter > 0):
		slowmo_counter = max(0, slowmo_counter - delta)
		if (slowmo_counter == 0):
			Engine.time_scale = 1

func stop_motion(time, scale = 0.1):
	slowmo_counter = time
	Engine.time_scale = scale
