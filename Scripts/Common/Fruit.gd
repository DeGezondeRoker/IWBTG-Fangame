extends AnimatableBody2D

## Speed of the fruit, makes it move and bounce (if not triggered) around by itself. Don't set this if the platform is a child of a movement controller!
@export var velocity := Vector2.ZERO
## Moves only when a certain event is triggered
@export var triggered := false
## Event ID that activates the fruit
@export var event_id := 0


func _ready():
	# Don't bounce if triggered
	if triggered:
		$CollisionShape2D.disabled = true


func _physics_process(_delta:float):
	if not Engine.is_editor_hint():
		if velocity != Vector2.ZERO and not (triggered and event_id not in Global.triggered_events):
			var collision := move_and_collide(velocity)
			if collision and not triggered:
				if abs(collision.get_normal().x) > abs(collision.get_normal().y):
					velocity.x *= -1
				elif abs(collision.get_normal().x) < abs(collision.get_normal().y):
					velocity.y *= -1
