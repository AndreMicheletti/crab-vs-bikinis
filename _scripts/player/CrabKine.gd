extends PlayerKine

export(int) var CLAW_SPEED = 250

onready var crab = get_node("Crab")
onready var body = get_node("Crab/Body")
onready var body_anim = get_node("Crab/Body/Anim")
onready var claw = get_node("Crab/Claws")
onready var claw_def = get_node("Crab/ClawDefend")
onready var claw_tween = get_node("Crab/Claws/Tween")
onready var claw_pos = get_node("Crab/ClawPos")
onready var claw_anim = get_node("Crab/Claws/Anim")
onready var claw_coll = get_node("Crab/Claws/Coll")
onready var skeleton: GDDragonBones = get_node("Crab/Body/CrabBones")

var flip = false
var attacking = false
var defending = false
var holding_target = null

# Called when the node enters the scene tree for the first time.
func _ready():
	skeleton.set("playback/curr_animation", "idle")
	skeleton.play(true)

func _process(delta):
	if (holding_target):
		_process_holding(delta)
	if (holding_target):
		return
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
	crab.scale = Vector2(-1 if flip else 1, 1)
	# Attack
	if Input.is_action_just_pressed("attack"):
		attack()
	._process(delta)

func _process_jump(delta):
	if defending:
		return
	._process_jump(delta)

func _physics_process(delta):
	if (holding_target):
		var hit_body = query_claw_collision()
		if not hit_body:
			release_target()
		return
	._physics_process(delta)
	if (defending):
		move_vec.x = 0
	if (not defending):
		if (moving and on_ground):
			skeleton.set("playback/curr_animation", "move")
		else:
			skeleton.set("playback/curr_animation", "idle")
	apply_movement(delta)

func process_defending():
	if (not on_ground):
		return
	var now_defending = Input.is_action_pressed("ui_down") and not attacking
	if (not defending and now_defending):
		# Start defend
		claw.global_rotation = PI if flip else 0.0
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

func _process_holding(_delta):
	if (not holding_target):
		return
	if Input.is_action_pressed("attack"):
		global_position = holding_target.global_position
	else:
		release_target()

func attack():
	if (attacking or defending):
		return
	attacking = true
	skeleton.set("playback/curr_animation", "attack")
	skeleton.set("playback/loop", 1)
	claw_anim.stop(true)
	claw_anim.play("claw_attack_fast")

func attack_hit():
	# Hit collide check
	var hit_body = query_claw_collision()
	if (hit_body):
		hit_body.emit_signal("hit")
		if Input.is_action_pressed("attack"):
			hold_target(hit_body)
	yield(get_tree().create_timer(0.1), "timeout")
	attacking = false
	skeleton.set("playback/loop", -1)

func query_claw_collision() -> PhysicsBody2D:
	var space_state = get_world_2d().direct_space_state
	# var collisions = space_state.intersect_point(claw_coll.global_position, 32, [], 4)
	var query = Physics2DShapeQueryParameters.new()
	query.set_shape(claw_coll.shape)
	query.collision_layer = 4
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.transform = claw_coll.global_transform
	query.motion = move_vec
	var collisions = space_state.intersect_shape(query, 1)
	for coll in collisions:
		var collider = coll["collider"]
		if collider.has_signal("hit"):
			return collider
	return null

func hold_target(target: Node2D):
	body_anim.play("hold")
	move_vec = Vector2(0, 0)
	var hold = Position2D.new()
	hold.set_name("Hold")
	target.add_child(hold)
	hold.global_position = global_position
	holding_target = hold

func release_target():
	body_anim.play("lose")
	holding_target = null
	move_vec = Vector2(0, 0)
	jumping = false
	on_ground = false

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

func _on_GroundCheck_body_entered(collbody):
	._on_GroundCheck_body_entered(collbody)

func _on_GroundCheck_body_exited(collbody):
	._on_GroundCheck_body_exited(collbody)
