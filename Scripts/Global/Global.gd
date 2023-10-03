extends Node

var kid_saved_pos := Vector2.ZERO
var kid_saved_facing := 1
var kid_saved_room_id := 1

var freeplay := true

var current_room := 0
var triggered_events := []

func _process(_delta:float):
	if Input.is_action_just_pressed("restart"):
		call_deferred("restart")

func load_room(room_id:int, entrance_id:int):
	triggered_events.clear()
	for i in $/root/Main.get_children():
		i.queue_free()
	var room_path := "res://Rooms/" + str(room_id) + ".tscn"
	var instance := load(room_path)
	var id: Node2D = instance.instantiate()
	var entrance := id.get_node("EntranceID" + str(entrance_id))
	var kid := id.get_node("Kid")
	kid.position = entrance.position
	kid.facing = entrance.scale.x
	if entrance.animation == 1:
		kid.state = 5
		kid.velocity.y = kid.S_JUMP_SPEED
	elif entrance.animation == 2:
		kid.state = 5
		kid.hlock = 20
		kid.velocity.x = kid.H_SPEED * entrance.scale.x
		kid.velocity.y = kid.D_JUMP_SPEED
	$/root/Main.add_child(id)
	current_room = room_id

func restart():
	var room_path := "res://Rooms/" + str(kid_saved_room_id) + ".tscn"
	var room: Node2D = load(room_path).instantiate()
	triggered_events.clear()
	for i in $/root/Main.get_children():
		i.queue_free()
	room.get_node("Kid").position = kid_saved_pos
	room.get_node("Kid").facing = kid_saved_facing
	$/root/Main.add_child(room)
	current_room = kid_saved_room_id

func load_game():
	var id: Node = load("res://Main.tscn").instantiate()
	id.name = "Main"
	$/root.add_child.call_deferred(id)
	call_deferred("restart")
