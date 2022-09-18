extends PlayerRigid

export(int) var CLAW_SPEED = 250

onready var body = get_node("CrabBody")
onready var claw = get_node("CrabBody/Claws")
onready var claw_def = get_node("CrabBody/ClawDefend")
onready var claw_tween = get_node("CrabBody/Claws/Tween")
onready var claw_pos = get_node("CrabBody/ClawPos")
onready var claw_anim = get_node("CrabBody/Claws/Anim")
onready var claw_coll = get_node("CrabBody/Claws/Coll")
onready var skeleton: GDDragonBones = get_node("CrabBody/CrabBones")

var flip = false
var attacking = false
var claw_return = false
var defending = false

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.set("playback/curr_animation", "idle")
	skeleton.play(true)

func _process(delta):
	var mouse_pos = get_global_mouse_position()
	flip = mouse_pos.x > global_position.x
	process_defending()
	if attacking or defending:
		return
	# Look
	var look_vec = mouse_pos - claw.global_position
	var rot = atan2(look_vec.y, look_vec.x)
	claw.global_rotation = PI - rot if flip else rot - PI
	# Turn
	body.scale = Vector2(-1 if flip else 1, 1)
	._process(delta)

func _physics_process(delta):
	_process_claw(delta)
	if defending or jumping:
		return
	._physics_process(delta)
	if (moving):
		skeleton.set("playback/curr_animation", "move")
	else:
		skeleton.set("playback/curr_animation", "idle")

func _process_claw(delta):
	if (not claw_return):
		return
	var target = claw_pos.global_position if not defending else global_position
	var move = claw.global_position.move_toward(target, delta * CLAW_SPEED)
	claw.global_position = move

func process_defending():
	if (jumping):
		return
	var now_defending = Input.is_action_pressed("ui_down") and not attacking
	if (not defending and now_defending):
		# Start defend
		claw.global_rotation = PI if flip else 0
		claw_tween.interpolate_property(claw, "global_position", claw.global_position, global_position, 
			0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		claw_tween.start()
		skeleton.set("playback/curr_animation", "defend_enter")
		skeleton.set("playback/loop", 1)
		skeleton.play(true)
	elif (defending and not now_defending):
		# Stop defend
		skeleton.set("playback/curr_animation", "defend_enter")
		skeleton.set("playback/loop", 1)
		skeleton.set("playback/speed", -1)
		skeleton.play(true)
		claw.global_position = claw_pos.global_position
		claw_tween.stop_all()
	defending = now_defending

func jump():
	if (attacking or defending or jumping):
		return
	.jump()

func attack():
	if (attacking or defending):
		return
	attacking = true
	claw_return = false
	var origin = claw.global_position
	var mouse = get_global_mouse_position()
	var one = origin.direction_to(mouse)
	var dist = min(origin.distance_to(mouse), 50)
	var target = origin + (one * dist)
	skeleton.set("playback/curr_animation", "attack")
	skeleton.set("playback/loop", 1)
	claw_anim.stop(true)
	claw_anim.play("claw_attack_fast")
	#claw_tween.interpolate_property(claw, "global_position", claw.global_position, target,
	#	0.3, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	#claw_tween.start()

func attack_hit():
	# Hit collide check 
	var space_state = get_world_2d().direct_space_state
	var collisions = space_state.intersect_point(claw_coll.global_position, 32, [], 2)
	for coll in collisions:
		if (coll["collider"].has_signal("hit")):
			coll["collider"].emit_signal("hit")
	# Claw Return Animation
	#claw_tween.interpolate_property(claw, "global_position", claw.global_position, claw.global_position,
	#	0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
	#claw_tween.start()
	#yield(claw_tween, "tween_completed")
	claw_return = true
	yield(get_tree().create_timer(0.2), "timeout")
	attacking = false
	skeleton.set("playback/loop", -1)

func _on_CrabBones_dragon_anim_complete(anim):
	print("anim complete ", anim)
	if (anim == "attack"):
		skeleton.set("playback/curr_animation", "idle")
		skeleton.set("playback/loop", -1)
		skeleton.set("playback/speed", 1)
		skeleton.play(true)
	if (anim == "defend_enter" and defending):
		skeleton.set("playback/curr_animation", "defend_loop")
		skeleton.set("playback/loop", -1)
		skeleton.set("playback/speed", 1)
		skeleton.play(true)

func _on_GroundCheck_body_entered(body):
	if (jumping):
		finish_jump()

func _on_GroundCheck_body_exited(body):
	jumping = true

func _on_Control_gui_input(event: InputEventMouseButton):
	if (event is InputEventMouseButton and event.pressed):
		if (event.button_index == 1):
			attack()
		elif (event.button_index == 2):
			Engine.time_scale = 1 if Engine.time_scale == 0.5 else 0.5

