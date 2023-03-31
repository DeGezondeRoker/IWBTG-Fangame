extends Node

var kid_saved_pos := Vector2.ZERO
var kid_saved_facing := 0


func _process(_delta:float):
	if Input.is_action_just_pressed("restart"):
		for i in $/root/Main.get_children():
			i.queue_free()
		var instance := load("res://Rooms/1.tscn")
		var id: Node2D = instance.instantiate()
		$/root/Main.add_child(id)
		id.get_node("Kid").position = kid_saved_pos
		id.get_node("Kid").facing = kid_saved_facing
