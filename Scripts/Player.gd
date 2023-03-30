extends CharacterBody2D

const H_SPEED := 150
const V_SPEED := 450
const S_JUMP_SPEED := -425
const D_JUMP_SPEED := -350
const GRAVITY := 20

var d_jump := true

func _ready():
	pass

func _process(delta):
	velocity.y += GRAVITY
	velocity.y = min(V_SPEED, velocity.y)

	velocity.x = Input.get_axis("left", "right") * H_SPEED

	move_and_slide()
	
	if is_on_floor():
		d_jump = true

	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			velocity.y = S_JUMP_SPEED
		elif d_jump:
			velocity.y = D_JUMP_SPEED
			d_jump = false
	
	if Input.is_action_just_released("jump") and velocity.y < 0:
		velocity.y *= 0.45
	
	_handle_animation()

func _handle_animation():
	if velocity.x > 0:
		$Sprite.flip_h = false
	elif velocity.x < 0:
		$Sprite.flip_h = true
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
