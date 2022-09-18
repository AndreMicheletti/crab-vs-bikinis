extends Node

var slowmo_counter = 0

var slowmo_frames = 0

func _ready():
	pass

func _process(delta):
	if (slowmo_counter > 0):
		slowmo_counter = max(0, slowmo_counter - delta)
		if (slowmo_counter == 0):
			Engine.time_scale = 1
	if (slowmo_frames > 0):
		slowmo_frames = max(0, slowmo_frames - 1)
		if (slowmo_frames == 0):
			Engine.time_scale = 1

func stop_motion(time, scale = 0.1):
	slowmo_counter = time
	Engine.time_scale = scale

func stop_frames(frames, scale = 0.1):
	slowmo_frames = frames
	Engine.time_scale = scale
