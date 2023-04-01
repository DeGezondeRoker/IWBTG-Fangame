extends Area2D

func _on_body_entered(body):
	if body.is_in_group("bullets") and $Sprite.frame == 0:
		var kid: CharacterBody2D = body.origin
		if kid.state != kid.STATES.STATE_DEAD:
			Global.kid_saved_pos = kid.position
			Global.kid_saved_facing = kid.facing
			$Timer.start()
			$Sprite.frame = 1

func _on_timer_timeout():
	$Sprite.frame = 0
