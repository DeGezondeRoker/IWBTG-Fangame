extends AnimatableBody2D

var facing := DIRECTIONS.RIGHT
var velocity := Vector2.ZERO
var moving := true
var origin : CharacterBody2D

enum DIRECTIONS {RIGHT = 1, LEFT = -1}


func _process(delta:float):
	$Sprite.flip_h = facing == -1
	if moving:
		velocity.x = 15 * facing * 50 * delta
		if move_and_collide(velocity):
			$AnimationPlayer.play("impact")
			$Timer2.start()
			$Timer.stop()
			moving = false


func _on_timer_timeout():
	queue_free()


func _on_timer_2_timeout():
	queue_free()
