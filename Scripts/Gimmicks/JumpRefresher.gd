extends Area2D


func _on_body_entered(body):
	if body.is_in_group("player"):
		body.d_jump = true
		set_deferred("monitoring", false)
		$Timer.start()
		$Sprite.frame = 1
		$Rotate.hide()
		$Rotate2.hide()


func _on_timer_timeout():
	set_deferred("monitoring", true)
	$Sprite.frame = 0
	$Rotate.show()
	$Rotate2.show()
