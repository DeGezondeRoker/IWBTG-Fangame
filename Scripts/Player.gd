extends CharacterBody2D

const H_SPEED := 150
const V_SPEED := 450
const S_JUMP_SPEED := -425
const D_JUMP_SPEED := -350
const GRAVITY := 20

var facing := 0
var d_jump := true
var platform_count := 0

var timer := 0

var state := 0

enum DIRECTIONS {RIGHT, LEFT}
enum STATES {STATE_DEFAULT, STATE_DEAD}

func _ready():
	pass


func _process(_delta:float):
	var function := "_update_" + str(STATES.keys()[state]).to_lower()
	call(function)
	
	if timer > 0:
		timer -= 1


func _update_state_default():
	velocity.y += GRAVITY
	velocity.y = min(V_SPEED, velocity.y)

	velocity.x = Input.get_axis("left", "right") * H_SPEED

	if velocity.x > 0:
		facing = DIRECTIONS.RIGHT
	elif velocity.x < 0:
		facing = DIRECTIONS.LEFT

	move_and_slide()

	if is_on_floor():
		d_jump = true

	if Input.is_action_just_pressed("jump"):
		if is_on_floor() or platform_count > 0:
			velocity.y = S_JUMP_SPEED
			d_jump = true
		elif d_jump:
			velocity.y = D_JUMP_SPEED
			d_jump = false
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.45
	
	_handle_animation()
	_handle_shoot()


func _update_state_dead():
	if timer > 0:
		var instance := load("res://Objects/Kid/BloodParticle.tscn")
		for i in 6:
			var id: AnimatableBody2D = instance.instantiate()
			get_parent().add_child(id)
			id.global_position = Vector2(global_position.x, global_position.y - 10)


func _handle_shoot():
	if Input.is_action_just_pressed("shoot"):
		var instance := load("res://Objects/Kid/Bullet.tscn")
		var id: AnimatableBody2D = instance.instantiate()
		get_parent().add_child(id)
		id.facing = facing
		id.origin = self
		id.global_position = Vector2(global_position.x, global_position.y - 10)


func _handle_animation():
	$Sprite.flip_h = facing
	$Bow.flip_h = facing
	if not is_on_floor():
		if velocity.y >= 0:
			$AnimationPlayer.play("fall")
		else:
			$AnimationPlayer.play("jump")
	else:
		if Input.get_axis("left", "right") and is_on_floor():
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.play("idle")


func kill_player():
	state = STATES.STATE_DEAD
	timer = 30
	$Sprite.hide()
	$Bow.hide()


func _on_area_detector_area_entered(area:Area2D):
	if area.is_in_group("killers"):
		kill_player()


func _on_area_detector_body_entered(body):
	if body.is_in_group("platforms"):
		platform_count += 1


func _on_area_detector_body_exited(body):
	if body.is_in_group("platforms"):
		platform_count -= 1
