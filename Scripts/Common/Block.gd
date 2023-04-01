@tool
extends AnimatableBody2D

@export_range(0, 1) var sprite := 0:
	set(new_sprite):
		sprite = new_sprite
		$Sprite.frame = sprite
