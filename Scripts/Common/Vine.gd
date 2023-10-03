@tool
extends Area2D

## The length of the vine, starts at 32px, increases by 16px per tick
@export_range(1, 100) var length := 1:
	set(new_length):
		length = new_length
		for i in $ExtraSprites.get_children():
			if i is Sprite2D:
				i.queue_free()

		$Collision.scale.y = 1 + (length - 1) * 0.5

		$SpriteB.position.y = 8 + (length - 1) * 8
		$SpriteT.position.y = -(8 + (length - 1) * 8)
		for i in length - 1:
			var sprite := Sprite2D.new()
			sprite.texture = load("res://Assets/Common/Vine.png")
			sprite.vframes = 3
			sprite.frame = 1
			sprite.position.x = -8
			sprite.position.y = i * 16 - (length - 2) * 8
			sprite.set_meta("_edit_lock_", true)
			$ExtraSprites.add_child(sprite)

enum DIRECTIONS {RIGHT = 1, LEFT = -1}
@export var facing: DIRECTIONS:
	set(new_facing):
		facing = new_facing
		scale.x = facing
