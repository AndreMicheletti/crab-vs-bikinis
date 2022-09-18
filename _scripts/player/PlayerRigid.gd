extends RigidBody2D

class_name PlayerRigid

export(int) var MOVE_SPEED = 20
export(int) var JUMP_FORCE = 300

var move_vec = Vector2()
var jumping = false
var moving = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _process(delta):
	# Jump
	if Input.is_action_just_pressed("ui_up"):
		jump()

func _physics_process(delta):
	# Move
	move_vec = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1 * MOVE_SPEED
	if Input.is_action_pressed("ui_right"):
		move_vec.x += 1 * MOVE_SPEED
	moving = move_vec.x != 0
	if (moving):
		apply_impulse(Vector2(0, 0), move_vec)

func jump():
	if (jumping):
		return
	jumping = true
	linear_damp = 1
	apply_impulse(Vector2(0, 0), Vector2(0, -JUMP_FORCE))

func finish_jump():
	jumping = false
	linear_damp = 2

func _on_GroundCheck_body_entered(body):
	if (jumping):
		finish_jump()

func _on_GroundCheck_body_exited(body):
	jumping = true

