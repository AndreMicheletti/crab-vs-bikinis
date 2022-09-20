extends KinematicBody2D

class_name PlayerKine

export(int) var MOVE_SPEED = 20
export(int) var JUMP_SPEED = 10
export(float) var GRAVITY_SPEED = 5
export(float) var JUMP_TIME_LIMIT = 1
export(Vector2) var MIN_POS = null
export(Vector2) var MAX_POS = null
export(NodePath) var body_shape = null

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
	if not jumping and not on_ground:
		move_vec.y += GRAVITY_SPEED * Engine.time_scale
	elif on_ground and not jumping:
		move_vec.y = 0
	move_vec = Vector2(0, move_vec.y)
	if Input.is_action_pressed("ui_left"):
		move_vec.x -= 1 * MOVE_SPEED
	if Input.is_action_pressed("ui_right"):
		move_vec.x += 1 * MOVE_SPEED
	moving = move_vec.x != 0

func apply_movement(delta):
	var move_delta = Vector2(move_vec.x * delta, move_vec.y * delta)
	var newX = min(MAX_POS.x, max(MIN_POS.x, global_position.x + move_delta.x))
	var newY = global_position.y + move_delta.y
	global_position = Vector2(newX, newY)
	if (move_vec.y > 0):
		fix_collision_bottom()

func fix_collision_bottom():
	var space_state = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	var shape_node = get_node(body_shape)
	var shape: RectangleShape2D = shape_node.shape
	query.set_shape(shape)
	query.collision_layer = 1
	query.collide_with_areas = true
	query.collide_with_bodies = true
	query.transform = shape_node.global_transform
	var result = space_state.intersect_shape(query, 1)
	if (result.size() > 0):
		var owner_id = result[0]["collider_id"]
		var shape_id = result[0]["shape"]
		var collider: StaticBody2D = result[0]["collider"]
		var coll_pos: Transform2D = collider.shape_owner_get_transform(shape_id)
		global_position.y = collider.global_position.y + coll_pos.origin.y - 90
		on_ground = true

func _process_jump(delta):
	# Jump
	if Input.is_action_pressed("ui_up"):
		if jump_timer < JUMP_TIME_LIMIT:
			jumping = true
			move_vec.y = -JUMP_SPEED
			jump_timer = min(jump_timer + delta, JUMP_TIME_LIMIT)
		else:
			jumping = false
	else:
		if jumping:
			jump_timer = JUMP_TIME_LIMIT
			jumping = false
		if on_ground:
			jump_timer = 0

func _on_GroundCheck_body_entered(body):
	on_ground = true

func _on_GroundCheck_body_exited(body):
	on_ground = false

