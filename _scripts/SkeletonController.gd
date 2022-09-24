extends GDDragonBones

class_name SkeletonController

signal anim_once_ended

var group_layers = {}
var group_loops = {}
var anim_name_group = {}

var layer_count = 100
var looping = false

func _ready():
	connect("dragon_anim_complete", self, "on_dragon_complete")
	# connect("dragon_fade_in_complete", self, "on_dragon_complete")

func play_loop(group: String, anim_name: String) -> void:
	var curr_layer = get_or_set_group_layer(group)
	group_loops[group] = anim_name
	play_new_animation(anim_name, curr_layer)
	set("playback/loop", 0)
	looping = true

func play_once(group: String, anim_name: String, times: int) -> void:
	var curr_layer = get_or_set_group_layer(group)
	anim_name_group[anim_name] = group
	play_new_animation(anim_name, curr_layer)
	set("playback/loop", times)
	looping = false

func play_separate(group: String, anim_name: String, times: int) -> void:
	if not looping: return
	fade_in(anim_name, 0, times, 1, group, GDArmatureDisplay.FadeOut_SameLayer)

func play_once_and_loop(group: String, single_anim: String, loop_anim: String, times = 1) -> void:
	play_loop(group, loop_anim)
	play_once(group, single_anim, times)

func on_dragon_complete(anim: String) -> void:
	if (anim_name_group.has(anim)):
		var group = anim_name_group[anim]
		if (group_loops.has(group)):
			print("fade in complete ", anim)
			var loop_anim = group_loops[group]
			var layer = group_layers[group]
			print("resuming anim ", loop_anim)
			emit_signal("anim_once_ended", anim)
			play_loop(group, loop_anim)
			anim_name_group.erase(anim)

func get_or_set_group_layer(group: String) -> int:
	if group_layers.has(group):
		return group_layers[group]
	else:
		var curr_layer = layer_count
		group_layers[group] = curr_layer
		layer_count -= 1
		return curr_layer
