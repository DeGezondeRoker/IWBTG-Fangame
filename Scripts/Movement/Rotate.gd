@tool
extends Node2D

## Rotate speed, in degrees per frame
@export var rotate_speed := 1.0

## Angle offset for all child nodes, in degrees
@export var offset := 0:
	set(new_offset):
		offset = new_offset % 360
		_set_properties()

## Radius, in pixels
@export var radius := 64:
	set(new_radius):
		radius = new_radius % 360
		_set_properties()

## Show a circle track in-game
@export var track := false

var angle := 0.0
var spacing := 0.0


func _ready():
	_set_properties()
	if not Engine.is_editor_hint() and track:
		_spawn_track()


func _physics_process(_delta:float):
	if not Engine.is_editor_hint():
		angle += deg_to_rad(rotate_speed)
		angle = wrapf(angle, -PI, PI)
		for i in get_children().size():
			var new_position := Vector2.ZERO
			new_position.x = cos(spacing * i + angle) * radius
			new_position.y = sin(spacing * i + angle) * radius
			get_children()[i].position = new_position


func _draw():
	if Engine.is_editor_hint():
		draw_arc(Vector2.ZERO, radius, 0, TAU, 50, Color(1.0, 1.0, 1.0))


func _set_properties():
	angle = deg_to_rad(offset)
	spacing = TAU / float(get_children().size())
	for i in get_children().size():
		var new_position := Vector2.ZERO
		new_position.x = cos(spacing * i + angle) * radius
		new_position.y = sin(spacing * i + angle) * radius
		get_children()[i].position = new_position
		if get_children()[i] == AnimatableBody2D:
				get_children()[i].sync_to_physics = true
	queue_redraw()


func _on_child_entered_tree(_node):
	_set_properties()


func _on_child_exiting_tree(node):
	angle = deg_to_rad(offset)
	spacing = TAU / float(get_children().size() - 1)
	for i in get_children().size():
		if get_children()[i] != node:
			var new_position := Vector2.ZERO
			new_position.x = cos(spacing * i + angle) * radius
			new_position.y = sin(spacing * i + angle) * radius
			get_children()[i].position = new_position


func _spawn_track():
	var instance := load("res://Objects/Movement/Rotate.tscn")
	var rotate_node: Node2D = instance.instantiate()
	rotate_node.rotate_speed = 0
	rotate_node.radius = radius
	rotate_node.position = position
	var track_node := load("res://Objects/Movement/TrackSprite.tscn")
	for i in int(radius/4):
		rotate_node.add_child(track_node.instantiate())
	get_parent().add_child.call_deferred(rotate_node)
