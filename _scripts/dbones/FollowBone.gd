extends Node2D

export(NodePath) var skeleton_path = null
export(String) var bone_name = ""
export (bool) var follow_pos = false
export (bool) var follow_scale = false
export (bool) var follow_rot = false

var skeleton: GDDragonBones = null

var origin_pos = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	origin_pos = transform.origin
	skeleton = get_node(skeleton_path)
	var bone: GDBone2D = get_bone()
	if (bone):
		get_parent().call_deferred("remove_child", self)
		bone.call_deferred("add_child", self)
		yield(self, "tree_entered")
		print("after change ", get_parent().name)
		transform.origin = Vector2(0, 0)
		position = Vector2(0, 0)

func _process(delta):
	var bone: GDBone2D = get_bone()
	if (bone):
		if (follow_pos):
			global_position = translate_bone_pos(bone)
		if (follow_rot):
			global_rotation = bone.get_bone_global_rotation()
		if (follow_scale):
			global_scale = bone.get_bone_global_scale()
	else:
		print("bone not found")

func translate_bone_pos(bone: GDBone2D) -> Vector2:
	var pos = bone.get_bone_global_position()
	return Vector2(pos.x, pos.y)

func get_bone() -> GDBone2D:
	return skeleton.get_armature().get_bone(bone_name)
