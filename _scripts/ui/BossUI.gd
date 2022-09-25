extends Control

onready var bar_base = get_node("BossBar/Base")
onready var bar_content = get_node("BossBar/Contents")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _on_Waitress_hit(health, max_health):
	var max_size = bar_base.rect_size
	print("health ", health)
	print("max_health ", max_health)
	var percent = float(health) / float(max_health)
	print("PERCENT ", percent)
	var size = Vector2(max_size.x * percent, max_size.y)
	print("SIZE ", size)
	bar_content.set_size(size)
