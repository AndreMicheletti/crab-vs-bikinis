extends Area2D

# Called when the node enters the scene tree for the first time.
func _ready():
	connect("body_entered", self, "_on_FallArea_body_entered")

func _on_FallArea_body_entered(body: Node2D):
	if (body.is_in_group("player")):
		GameController.emit_signal("game_over")
