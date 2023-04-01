extends AnimatableBody2D

var facing := 0
var velocity := Vector2.ZERO
var moving := true
var origin : CharacterBody2D

enum DIRECTIONS {RIGHT, LEFT}


func _process(_delta:float):
	if moving:
		velocity.x = 15 if facing == 0 else -15
		if move_and_collide(velocity):
			moving = false
			queue_free() # Will get an animation as opposed to just disappearing


func _on_timer_timeout():
	queue_free()
