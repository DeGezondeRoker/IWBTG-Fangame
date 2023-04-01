@tool
extends AnimatableBody2D

@export_range(1, 100) var length := 1:
	set(new_length):
		length = new_length
		for i in $ExtraSprites.get_children():
			if i is Sprite2D:
				i.queue_free()

		$CollisionShape2D.scale.x = 1 + (length - 1) * 0.5
		$CollisionShape2D.position.x = 16 + (length - 1) * 8

		$SpriteR.position.x = 24 + (length - 1) * 16
		for i in length - 1:
			var sprite := Sprite2D.new()
			sprite.texture = load("res://Assets/Common/Platform.png")
			sprite.hframes = 3
			sprite.frame = 2
			sprite.position.x = 24 + (i) * 16
			sprite.position.y = 8
			sprite.set_meta("_edit_lock_", true)
			$ExtraSprites.add_child(sprite)
