extends Area2D

func _on_body_entered(body):
	if body.is_in_group("bullets") and $Sprite.frame == 0:
		Global.kid_saved_pos = body.origin.position
		Global.kid_saved_facing = body.origin.facing
		$Timer.start()
		$Sprite.frame = 1

func _on_timer_timeout():
	$Sprite.frame = 0
