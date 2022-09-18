extends Node2D

onready var skeleton: GDDragonBones = get_node("Skeleton")

func _ready():
	pass

func _on_LeftBoob_hit():
	print("hit left boob")
	GameController.stop_frames(12)
	skeleton.fade_in("hit_left", 0, 1, 0, "default", GDArmatureDisplay.FadeOut_None)
