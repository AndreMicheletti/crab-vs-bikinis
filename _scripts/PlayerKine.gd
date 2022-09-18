extends KinematicBody2D

class_name PlayerKine

export(int) var MOVE_SPEED = 20
export(int) var GRAVITY_FORCE = 1
export(int) var JUMP_FORCE = 10

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
	var gravity = GRAVITY_FORCE / Engine.time_scale if move_vec.y < 0 else GRAVITY_FORCE
	var y = move_vec.y + (gravity * delta) if (jumping) else 0
	move_vec = Vector2(0, y)
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1 * MOVE_SPEED * delta
	if Input.is_action_pressed("ui_right"):
		move_vec.x += 1 * MOVE_SPEED * delta
	moving = move_vec.x != 0

func apply_movement():
	move_and_collide(move_vec)

func jump():
	if (jumping):
		return
	jumping = true
	move_vec.y = -JUMP_FORCE

func finish_jump():
	jumping = false

func _on_GroundCheck_body_entered(body):
	if (jumping):
		finish_jump()

func _on_GroundCheck_body_exited(body):
	jumping = true

