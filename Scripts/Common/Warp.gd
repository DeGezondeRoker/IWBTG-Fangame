extends Area2D

@export var room_id := 2
@export var entrance_id := 0
@export var animation := false


func _on_body_entered(body):
	if body.is_in_group("player"):
		if body.state != Globals.STATES.EXIT_WARP:
			if animation:
				body.state = Globals.STATES.WARP
				body.target = position
				body.target.y += 12
				$Timer.wait_time = .4
				$Timer.start()
			else:
				_warp_player()


func _on_timer_timeout():
	_warp_player()


func _warp_player():
	if room_id != Global.current_room:
		Global.call_deferred("load_room", room_id, entrance_id)
		return
	var entrance := get_parent().get_node("EntranceID" + str(entrance_id))
	var kid := get_parent().get_node("Kid")
	kid.position = entrance.position
	kid.facing = entrance.scale.x
	if entrance.animation == 1:
		kid.state = Globals.STATES.EXIT_WARP
		kid.velocity.y = kid.S_JUMP_SPEED
	elif entrance.animation == 2:
		kid.state = Globals.STATES.EXIT_WARP
		kid.hlock = 20
		kid.velocity.x = kid.H_SPEED * entrance.scale.x
		kid.velocity.y = kid.D_JUMP_SPEED
