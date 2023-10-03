extends Node2D

enum CameraModes {SCREEN_LOCK, KID_TRACKING, KID_TRACKING_ZOOM}
@export var camera_mode: CameraModes
var smooth_screen_lock := true
var level_camera

func _ready():
	Global.current_room = int(str(self.name))
	if self in get_node("/root/").get_children():
		Global.kid_saved_room_id = Global.current_room
		Global.load_game()
		queue_free()
	
	if camera_mode == CameraModes.SCREEN_LOCK:
		if not get_node_or_null("Camera2D"):
			level_camera = Camera2D.new()
		else:
			level_camera = $Camera2D
		if smooth_screen_lock:
			level_camera.position_smoothing_enabled = true
			level_camera.position_smoothing_speed = 10
		level_camera.position.x = floor($Kid.position.x / 800) * 800 + 400
		level_camera.position.y = floor($Kid.position.y / 608) * 608 + 304
		level_camera.enabled = true
		if not get_node_or_null("Camera2D"):
			add_child(level_camera)
	elif camera_mode == CameraModes.KID_TRACKING or camera_mode == CameraModes.KID_TRACKING_ZOOM:
		if get_node_or_null("Camera2D"):
			$Camera2D.queue_free()
		level_camera = Camera2D.new()
		if camera_mode == CameraModes.KID_TRACKING_ZOOM:
			level_camera.zoom = Vector2(2,2)
		$Kid.add_child(level_camera)

func _process(_delta:float):
	if camera_mode == CameraModes.SCREEN_LOCK:
		level_camera.position.x = floor($Kid.position.x / 800) * 800 + 400
		level_camera.position.y = floor($Kid.position.y / 608) * 608 + 304
