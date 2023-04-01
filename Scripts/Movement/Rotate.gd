@tool
extends Node2D

@export var rotate_speed := 1.0

@export var offset := 0:
	set(new_offset):
		offset = new_offset % 360
		_set_properties()

@export var radius := 0:
	set(new_radius):
		radius = new_radius % 360
		_set_properties()

var angle := 0.0
var spacing := 0.0


func _ready():
	_set_properties()


func _process(_delta:float):
	if not Engine.is_editor_hint():
		angle += deg_to_rad(rotate_speed)
		angle = wrapf(angle, -PI, PI)
		for i in get_children().size():
			var new_position := Vector2.ZERO
			new_position.x = cos(spacing * i + angle) * radius
			new_position.y = sin(spacing * i + angle) * radius
			get_children()[i].position = new_position


func _set_properties():
	angle = deg_to_rad(offset)
	spacing = 2 * PI / float(get_children().size())
	for i in get_children().size():
		var new_position := Vector2.ZERO
		new_position.x = cos(spacing * i + angle) * radius
		new_position.y = sin(spacing * i + angle) * radius
		get_children()[i].position = new_position


func _on_child_entered_tree(_node):
	_set_properties()


func _on_child_exiting_tree(node):
	angle = deg_to_rad(offset)
	spacing = 2 * PI / float(get_children().size() - 1)
	for i in get_children().size():
		if get_children()[i] != node:
			var new_position := Vector2.ZERO
			new_position.x = cos(spacing * i + angle) * radius
			new_position.y = sin(spacing * i + angle) * radius
			get_children()[i].position = new_position
