extends Node2D

export(Vector2) var DEFAULT_POS = Vector2(0, 0)

onready var skeleton: SkeletonController = get_node("Skeleton")
onready var anim = get_node("Anim")
onready var action_timer = get_node("ActionTimer")
onready var tween = get_node("Tween")

onready var hitboxes = {
	"attack_unarmed": get_node("Skeleton/Hitbox/UnarmedHitbox"),
	"attack_armed": get_node("Skeleton/Hitbox/ArmedHitbox"),
	"attack_armed_sweep": get_node("Skeleton/Hitbox/ArmedSweepHitbox")
}

var armed = false
var throw_idx = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.play_loop("body", "idle")
	skeleton.set("playback/play", true)
	#action_timer.connect("timeout", self, "on_action_timer")
	#action_timer.start()
	sequence_reset()


func sequence_reset():
	armed = false
	skeleton.set("playback/curr_animation", "idle")
	tween.interpolate_property(self, "global_position", global_position, DEFAULT_POS, 
		0.5, Tween.TRANS_CIRC, Tween.EASE_IN_OUT)
	tween.start()
	yield(tween, "tween_completed")
	yield(get_tree().create_timer(1), "timeout")
	randomize()
	if randi() % 2 == 0:
		sequence_unarmed(randi() % 6 + 2)
		# sequence_throw()
	else:
		sequence_throw()

func sequence_unarmed(times: int):
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
	yield(attack_unarmed(), "completed")
	sequence_unarmed(times - 1)

func sequence_throw(reset = false):
	skeleton.set("playback/curr_animation", "idle_armed")
	if reset: skeleton.play_loop("body", "idle")
	else: skeleton.play_loop("body", "idle_armed")
	if not armed:
		yield(armed_in(), "completed")
	yield(get_tree().create_timer(0.2), "timeout")
	skeleton.set("playback/speed", 1.5)
	yield(armed_throw(3), "completed")
	skeleton.set("playback/speed", 1)
	if reset: sequence_reset()
	else:
		yield(get_tree().create_timer(0.2), "timeout")
		sequence_armed(1)

func sequence_armed(rand: int):
	randomize()
	if (rand > 0):
		if rand == 1: yield(attack_armed_sweep(), "completed")
		if rand > 1: yield(attack_armed(), "completed")
		yield(get_tree().create_timer(0.4), "timeout")
		sequence_armed(randi() % 3)
	else:
		yield(get_tree().create_timer(0.4), "timeout")
		sequence_throw(true)

func attack_armed():
	skeleton.play_once("body", "attack_armed", 1)
	yield(skeleton, "anim_once_ended")

func attack_armed_sweep():
	skeleton.play_once("body", "attack_armed_sweep", 1)
	yield(skeleton, "anim_once_ended")

func armed_in():
	skeleton.play_once("body", "armed_in", 1)
	yield(skeleton, "anim_once_ended")
	armed = true

func armed_throw(times = 1):
	throw_idx = 0
	skeleton.play_once("body", "attack_throw", times)
	yield(skeleton, "anim_once_ended")

func attack_unarmed():
	skeleton.play_once("body", "attack_unarmed", 1)
	yield(skeleton, "anim_once_ended")

func hit():
	GameController.stop_frames(8)
	$Anim.play("hit")

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
		anim.play("bottle_" + str(throw_idx))
		throw_idx += 1
		return
	var active = ev_name == "attackHitStart"
	var hitbox = hitboxes.get(animation, null)
	if hitbox:
		hitbox.set_active(active)
