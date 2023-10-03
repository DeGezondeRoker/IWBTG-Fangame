@tool
extends AnimatableBody2D

## Speed of the platform, makes it move and bounce around by itself. Don't set this if the platform is a child of a movement controller!
@export var velocity := Vector2.ZERO

## The length of the platform, starts at 32px, increases by 16px per tick
@export_range(1, 100) var length := 1:
	set(new_length):
		length = new_length
		for i in $ExtraSprites.get_children():
			if i is Sprite2D:
				i.queue_free()

		$Collision.scale.x = 1 + (length - 1) * 0.5
		$Collision.position.x = 0
		$KidCollision/Collision.scale.x = 1 + (length - 1) * 0.5
		$KidCollision/Collision.position.x = 0

		$SpriteR.position.x = 8 + (length - 1) * 8
		$SpriteL.position.x = -(8 + (length - 1) * 8)
		for i in length - 1:
			var sprite := Sprite2D.new()
			sprite.texture = load("res://Assets/Common/Platform.png")
			sprite.hframes = 3
			sprite.frame = 2
			sprite.position.x = i * 16 - (length - 2) * 8
			sprite.set_meta("_edit_lock_", true)
			$ExtraSprites.add_child(sprite)

func _physics_process(_delta:float):
	if not Engine.is_editor_hint():
		if velocity != Vector2.ZERO:
			var collision := move_and_collide(velocity)
			if collision:
				if collision.get_normal().x != 0:
					velocity.x *= -1
				if collision.get_normal().y != 0:
					velocity.y *= -1
