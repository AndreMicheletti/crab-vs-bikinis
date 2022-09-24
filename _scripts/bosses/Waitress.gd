extends Node2D

export(float) var MOVE_SPEED = 100
export(Vector2) var MIN_POS = Vector2(0, 0)
export(Vector2) var MAX_POS = Vector2(0, 0)

onready var skeleton: SkeletonController = get_node("Skeleton")
onready var anim = get_node("Anim")
onready var action_timer = get_node("ActionTimer")
onready var tween = get_node("Tween")

var moving = true
var dir = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.play_loop("body", "idle")
	skeleton.set("playback/play", true)
	action_timer.connect("timeout", self, "on_action_timer")
	action_timer.start()

func _physics_process(delta):
	if not moving: return
	var start_pos = global_position
	var move = Vector2(MOVE_SPEED * dir * delta, 0)
	var move_x = clamp(start_pos.x + move.x, MIN_POS.x, MAX_POS.x)
	global_position = Vector2(move_x, start_pos.y)
	if global_position == MIN_POS:
		skeleton.scale.x = -1
		dir = 1
	elif global_position == MAX_POS:
		skeleton.scale.x = 1
		dir = -1

func on_action_timer():
	print("ACTION TIMER")
	skeleton.play_once("body", "attack_unarmed", 1)
	moving = false
	yield(skeleton, "anim_once_ended")
	moving = true

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
	var hitbox = null
	var active = ev_name == "attackHitStart"
	if animation == "attack_unarmed":
		hitbox = $Skeleton/UnarmedHitbox
	if hitbox:
		hitbox.set_active(active)
