extends Node2D

signal hit

export(Vector2) var DEFAULT_POS = Vector2(0, 0)
export(NodePath) var BOTTLE_PARENT = null
export(Array, Vector2) var BOTTLE_POS = []
export(Resource) var BOTTLE_SCN = null
export(int) var MAX_HEALTH = 100

onready var skeleton: SkeletonController = get_node("Skeleton")
onready var anim = get_node("Anim")
onready var tween = get_node("Tween")

onready var hitboxes = {
	"attack_unarmed": get_node("Skeleton/Hitbox/UnarmedHitbox"),
	"attack_armed": get_node("Skeleton/Hitbox/ArmedHitbox"),
	"attack_armed_sweep": get_node("Skeleton/Hitbox/ArmedSweepHitbox")
}

var throw_idx = 0
var health = 0
var recover = false

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.play_loop("body", "idle")
	skeleton.set("playback/play", true)
	health = MAX_HEALTH
	sequence_reset()

func sequence_reset():
	skeleton.set("playback/curr_animation", "idle")
	tween.interpolate_property(self, "global_position", global_position, DEFAULT_POS, 
		0.5, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(1), "timeout")
	randomize()
	if randi() % 2 == 0:
		sequence_melee(randi() % 6 + 2)
	else:
		sequence_throw()

func sequence_melee(times: int):
	randomize()
	if (times <= 0):
		sequence_reset()
		return
	yield(get_tree().create_timer(0.4), "timeout")
	var goto_x = GameController.player.global_position.x  + 280
	var start = global_position
	tween.interpolate_property(self, "global_position", start, Vector2(goto_x, start.y), 
		0.5, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	if randi() % 2 == 0:
		yield(attack_armed(), "completed")
	else:
		yield(attack_armed_sweep(), "completed")
	sequence_melee(times - 1)

func sequence_throw():
	yield(get_tree().create_timer(0.2), "timeout")
	skeleton.set("playback/speed", 1.5)
	yield(armed_throw(3), "completed")
	skeleton.set("playback/speed", 1)
	yield(get_tree().create_timer(0.2), "timeout")
	sequence_reset()

func attack_armed():
	skeleton.play_once("body", "attack_armed", 1)
	yield(skeleton, "anim_once_ended")

func attack_armed_sweep():
	skeleton.play_once("body", "attack_armed_sweep", 1)
	yield(skeleton, "anim_once_ended")

func armed_throw(times = 1):
	throw_idx = 0
	skeleton.play_once("body", "attack_throw", times)
	yield(skeleton, "anim_once_ended")

func hit():
	if recover: return
	GameController.stop_frames(8)
	health = max(health -1, 0)
	$Anim.play("hit")
	emit_signal("hit", health, MAX_HEALTH)
	yield(get_tree().create_timer(0.1), "timeout")
	recover = true

func hit_recover():
	recover = false

func spawn_bottle(pos_idx: int):
	$Bottle/Anim.play("throw")
	var bottle_layer = get_node(BOTTLE_PARENT)
	var bottle = BOTTLE_SCN.instance()
	var pos = BOTTLE_POS[pos_idx]
	bottle_layer.add_child(bottle)
	bottle.global_position = pos

func _on_LeftBoob_hit():
	skeleton.play_separate("boobs_left", "hit_left", 1)
	hit()

func _on_RightBoob_hit():
	skeleton.play_separate("boobs_right", "hit_right", 1)
	hit()

func _on_Skeleton_dragon_anim_event(event):
	var animation = event["animation"]
	var ev_name = event["event_name"]
	if ev_name == "attackThrow":
		spawn_bottle(throw_idx)
		throw_idx += 1
		return
	var active = ev_name == "attackHitStart"
	var hitbox = hitboxes.get(animation, null)
	if hitbox:
		hitbox.set_active(active)
