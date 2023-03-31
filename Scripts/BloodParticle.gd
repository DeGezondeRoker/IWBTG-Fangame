extends AnimatableBody2D

var velocity := Vector2.ZERO
var gravity := randf_range(0.15, 0.25)
var moving := true

func _ready():
	$Sprite.frame = randi_range(0, 6)
	var speed := randf_range(0, 6)
	var angle := randf_range(0, TAU)
	velocity.x = cos(angle) * speed
	velocity.y = sin(angle) * speed

func _process(_delta:float):
	if moving:
		if move_and_collide(velocity):
			moving = false
	velocity.y += gravity

# Small buffer to prevent blood from all getting stuck in one spot
func _on_timer_timeout():
	$CollisionShape2D.disabled = false
