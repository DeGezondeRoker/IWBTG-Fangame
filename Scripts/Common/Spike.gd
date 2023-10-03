@tool
extends Area2D

enum styles {NORMAL, MINI, SPIKEBED}
## Spike size/style
@export var style: styles:
	set(new_style):
		style = new_style
		$Sprite.frame = style
		var key := "CollisionPolygon" + str(style)
		for i in get_children():
			if i is CollisionPolygon2D:
				i.disabled = i.name != key
