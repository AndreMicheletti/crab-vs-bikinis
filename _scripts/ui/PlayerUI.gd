extends Control

export(float) var AUTO_HIDE = 1.0

func _ready():
	update_health(3)

func update_health(health: int):
	$HealthBar/Health.visible = health > 0
	$HealthBar/Health2.visible = health > 1
	$HealthBar/Health3.visible = health > 2

func show():
	$AutoHide.stop()
	$Tween.stop_all()
	$Tween.interpolate_property(self, "modulate", self.modulate, Color.white, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func hide():
	$AutoHide.stop()
	$Tween.stop_all()
	$Tween.interpolate_property(self, "modulate", self.modulate, Color.transparent, 0.5, Tween.TRANS_CUBIC, Tween.EASE_OUT)
	$Tween.start()

func _on_AutoHide_timeout():
	hide()

func _on_Crab_health_changed(crab):
	update_health(crab.health)
	show()

func _on_Tween_tween_completed(object, key):
	if (modulate == Color.white):
		print("start autohide playerui")
		$AutoHide.start()
