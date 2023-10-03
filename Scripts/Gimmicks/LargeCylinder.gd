@tool
extends Node2D

## The length of the cylinder, starts at 32px, increases by 32px per tick
@export_range(1, 100) var length := 1:
	set(new_length):
		length = new_length

		$Collision.scale.x = 1 + (length - 1)
		$ColorRect.scale.x = 1 + (length - 1)
		$ExitArea.scale.x = 1 + ((length - 1) * 2)
		$ColorRect.position.x = -((length - 1) * 16 + 16)

var falling := false
var touching_players = []

func kid_collided(kid, _collision):
	if kid.state == Globals.STATES.DEFAULT:
		if kid.on_floor:
			kid.cylinder_timer = PI / 2
			kid.state = Globals.STATES.CYLINDER
			kid.current_cylinder = self
		elif kid.on_ceiling:
			kid.cylinder_timer = 3 * PI / 2
			kid.state = Globals.STATES.CYLINDER
			kid.current_cylinder = self
