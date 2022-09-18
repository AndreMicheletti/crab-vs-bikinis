extends KinematicBody2D

class_name PlayerKine

export(int) var MOVE_SPEED = 20
export(int) var JUMP_SPEED = 10
export(float) var GRAVITY_SPEED = 5
export(float) var JUMP_TIME_LIMIT = 1

var move_vec = Vector2()
var jumping = false
var on_ground = false
var moving = false

var jump_timer = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	_process_jump(delta)

func _physics_process(delta):
	# Move
	if (not jumping and not on_ground):
		move_vec.y += GRAVITY_SPEED
	move_vec = Vector2(0, move_vec.y)
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1 * MOVE_SPEED
	if Input.is_action_pressed("ui_right"):
		move_vec.x += 1 * MOVE_SPEED
	moving = move_vec.x != 0

func apply_movement(delta):
	var move_delta = Vector2(move_vec.x * delta, move_vec.y * delta)
	var newX = min(970, max(48, global_position.x + move_delta.x))
	var newY = min(510, global_position.y + move_delta.y)
	global_position = Vector2(newX, newY)
	# move_and_collide(move_delta)

func _process_jump(delta):
	# Jump
	if Input.is_action_pressed("ui_up") and jump_timer < JUMP_TIME_LIMIT:
		jumping = true
		move_vec.y = -JUMP_SPEED
		jump_timer = min(jump_timer + delta, JUMP_TIME_LIMIT)
	else:
		jumping = false

func _on_GroundCheck_body_entered(body):
	on_ground = true
	jump_timer = 0

func _on_GroundCheck_body_exited(body):
	on_ground = false

