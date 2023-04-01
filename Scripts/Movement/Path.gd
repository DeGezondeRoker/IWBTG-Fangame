@tool
extends Path2D

@export var speed := 1.0
@export var reverse := false
@export var reverse_at_end := false


func _ready():
	if not Engine.is_editor_hint():
		for i in get_children():
			if not i is PathFollow2D:
				var pathfollow := PathFollow2D.new()
				pathfollow.rotates = false
				pathfollow.set_meta("reverse", reverse)
				add_child(pathfollow)
				remove_child(i)
				pathfollow.add_child(i)
				pathfollow.progress = curve.get_closest_offset(i.position)
				i.position = Vector2.ZERO


func _process(_delta:float):
	if not Engine.is_editor_hint():
		for i in get_children():
			if i is PathFollow2D:
				if i.progress_ratio == 1 and reverse_at_end:
					i.set_meta("reverse", 1)
				elif i.progress_ratio == 0 and reverse_at_end:
					i.set_meta("reverse", 0)
				i.progress += speed * (-1 if i.get_meta("reverse") else 1)

	if Engine.is_editor_hint():
		for i in get_children():
			if not i is PathFollow2D and not i is Sprite2D:
				i.position = curve.sample_baked(curve.get_closest_offset(i.position))
			elif i is Sprite2D:
				i.queue_free()

		# Draw a track, need to get this working some day..
#		if curve != null:
#			for i in curve.point_count:
#				var sprite := Sprite2D.new()
#				sprite.texture = load("res://Assets/Movement/Track.png")
#				sprite.hframes = 2
#				sprite.frame = 0
#				sprite.position = curve.get_point_position(i)
#				sprite.set_meta("_edit_lock_", true)
#				add_child(sprite)

#			for i in curve.get_baked_length() / 16:
#				var sprite := Sprite2D.new()
#				sprite.texture = load("res://Assets/Movement/Track.png")
#				sprite.hframes = 2
#				sprite.frame = 1
#				#sprite.position = curve.get_baked_points()[i * 5 + 2]
#				sprite.set_meta("_edit_lock_", true)
#				add_child(sprite)
