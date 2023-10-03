@tool
extends Path2D

## Speed, in pixels per frame
@export var speed := 1.0
## Reverse direction
@export var reverse := false
enum PathModes {LOOP, REVERSE, STOP}
## Makes the direction of child nodes reverse when they reach the end of the path
@export var mode: PathModes
## Moves only when a certain event is triggered
@export var triggered := false
## Event ID that activates the path
@export var event_id := 0

func _ready():
	if not Engine.is_editor_hint():
		for i in get_children():
			if not i is PathFollow2D:
				var pathfollow := PathFollow2D.new()
				pathfollow.rotates = false
				pathfollow.set_meta("reverse", reverse)
				pathfollow.set_meta("stopped", triggered)
				if mode != PathModes.LOOP:
					pathfollow.loop = false
				add_child(pathfollow)
				remove_child(i)
				pathfollow.add_child(i)
				pathfollow.progress = curve.get_closest_offset(i.position)
				i.position = Vector2.ZERO


func _physics_process(_delta:float):
	if not Engine.is_editor_hint():
		for i in get_children():
			if i is PathFollow2D:
				if triggered:
					i.set_meta("stopped", event_id not in Global.triggered_events)
				if i.progress_ratio == 1:
					if mode == PathModes.REVERSE:
						i.set_meta("reverse", true)
				elif i.progress_ratio == 0 and mode == PathModes.REVERSE:
					i.set_meta("reverse", 0)
				if not i.get_meta("stopped"):
					i.progress += speed * (-1 if i.get_meta("reverse") else 1)

	if Engine.is_editor_hint():
		if curve != null:
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
