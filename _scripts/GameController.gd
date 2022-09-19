extends Node

var game_scene = "res://_scenes/Main.tscn"
var title_scene = "res://_scenes/TitleScreen.tscn"

signal game_over

var slowmo_counter = 0
var slowmo_frames = 0

func _ready():
	connect("game_over", self, "on_game_over")

func on_game_over():
	var res = get_tree().change_scene(title_scene)

func start_game():
	var res = get_tree().change_scene(game_scene)

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
