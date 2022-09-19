extends Node2D

onready var skeleton: GDDragonBones = get_node("Skeleton")
onready var anim = get_node("Anim")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	# anim.play("move")

func _on_LeftBoob_hit():
	skeleton.fade_in("hit_left", 0, 1, 0, "default", GDArmatureDisplay.FadeOut_None)
	GameController.stop_frames(8)
