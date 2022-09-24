extends Area2D

export(float) var COOLDOWN_TIME = 0.2

var active = false
var cooldown = false

func _ready():
	collision_mask = 2
	collision_layer = 2

func set_active(val: bool):
	active = val
	cooldown = false

func _physics_process(delta):
	if (active and not cooldown):
		query_hit()

func start_cooldown():
	cooldown = true
	yield(get_tree().create_timer(COOLDOWN_TIME), "timeout")
	cooldown = false

func query_hit():
	var space_state = get_world_2d().direct_space_state
	var query = Physics2DShapeQueryParameters.new()
	var shape_node = get_node("Coll")
	var shape: Shape2D = shape_node.shape
	query.set_shape(shape)
	query.collision_layer = 2
	query.collide_with_areas = false
	query.collide_with_bodies = true
	query.transform = shape_node.global_transform
	var result = space_state.intersect_shape(query, 1)
	if (result.size() > 0):
		var collider = result[0]["collider"]
		print(" HITBOX HIT ", collider)
		start_cooldown()
		collider.hit()
