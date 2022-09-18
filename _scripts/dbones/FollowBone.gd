extends Node2D

export(NodePath) var skeleton_path = null
export(String) var bone_name = ""
export (bool) var follow_pos = false
export (bool) var follow_scale = false
export (bool) var follow_rot = false

var skeleton: GDDragonBones = null

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton = get_node(skeleton_path)

func _process(delta):
	var bone = get_bone()
	if (bone):
		if (follow_pos):
			global_position = bone.get_bone_global_position()
		if (follow_rot):
			# global_rotation = bone.get_bone_global_rotation()
			rotation = bone.get_bone_rotation()
		if (follow_scale):
			scale = bone.get_bone_global_scale()

func get_bone() -> GDBone2D:
	return skeleton.get_armature().get_bone(bone_name)
