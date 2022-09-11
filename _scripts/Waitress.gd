extends Node2D

onready var skeleton: GDDragonBones = get_node("Skeleton")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_LeftBoob_hit():
	skeleton.fade_in("hit_left", 0, 1, 0, "default", GDArmatureDisplay.FadeOut_None)
