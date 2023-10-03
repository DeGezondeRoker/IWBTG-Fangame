extends CharacterBody2D

# Physics constants
const H_SPEED := 150 # Walking speed
const V_SPEED := 450 # Max falling speed
const S_JUMP_SPEED := -425
const D_JUMP_SPEED := -350
const GRAVITY := 20.0
const VINE_SPEED := 100 # Speed at which the player slides down a vine

# General variables
var facing := DIRECTIONS.RIGHT # Which way the player is facing
var d_jump := true # If the player can double jump
var jumping := true # If the player is actually jumping instead of bouncing (e.g. from a spring)
var timer := 0 # General timer var
var hlock := 0 # Locks horizontal speed changes (used for vines, springs etc.)
var state := 0 # See state enum
var mimic_original_collision := true # Toggle to change some move and slide stuff to be more accurate to original (see _update_state_default())
var was_on_floor := true # Tracks if the player was on the floor last frame
var last_velocity := Vector2.ZERO # Velocity of player on last frame
var target := Vector2.ZERO # Used for warped state
var next_state := 0 # Used to queue a next state (used with state timer node)
var decelerate := 0
var on_floor := false
var on_ceiling := false
var on_wall := false

# Level object variables
var platform_count := 0 # Used to see if the player is inside an IWBTG platform (and thus can jump)
var vines := [] # Used to keep track of vines the player is touching
var current_cylinder # Used to store the large cylinder node the player is in contact with
var cylinder_timer := 0.0 # Used to keep track of how far along a cylinder the player is

enum DIRECTIONS {RIGHT = 1, LEFT = -1}

func _ready():
	if Global.freeplay and Global.kid_saved_pos == Vector2.ZERO:
		Global.kid_saved_pos = position


func _physics_process(_delta:float):
	var function := "_update_state_" + str(Globals.STATES.keys()[state]).to_lower()
	call(function)
	
	if $Sprite.flip_h:
		$Sprite.offset.x = 1
		$JumpEffect.position.x = 2
		$DJumpEffect.position.x = 2
	else:
		$Sprite.offset.x = 0
		$JumpEffect.position.x = -2
		$DJumpEffect.position.x = -2
	
	if Input.is_action_pressed("teleport player"):
		position = get_global_mouse_position()
		$Sprite.show()
		state = Globals.STATES.DEFAULT
	
	if timer > 0:
		timer -= 1
	if hlock > 0:
		hlock -= 1


func _update_state_default():
	velocity.y += GRAVITY
	velocity.y = min(V_SPEED + GRAVITY, velocity.y)

	if not hlock:
		# Decelerating (from springs)
		if decelerate == DIRECTIONS.LEFT:
			if velocity.x > 0: # Has the player slowed down fully yet?
				velocity.x -= 20
				if Input.get_axis("left", "right") == DIRECTIONS.LEFT: # Player is trying to slow down
					velocity.x -= 10
				elif Input.get_axis("left", "right") == DIRECTIONS.RIGHT and velocity.x < H_SPEED: # Player is trying to keep moving, so don't slow down to 0 fully
					velocity.x = H_SPEED
					decelerate = 0
			else: # Slowed down
				velocity.x = 0
				decelerate = 0
		elif decelerate == DIRECTIONS.RIGHT:
			if velocity.x < 0:
				velocity.x += 20
				if Input.get_axis("left", "right") == DIRECTIONS.RIGHT:
					velocity.x += 10
				elif Input.get_axis("left", "right") == DIRECTIONS.LEFT and velocity.x > -H_SPEED:
					velocity.x = -H_SPEED
					decelerate = 0
			else:
				velocity.x = 0
				decelerate = 0
		else:
			velocity.x = Input.get_axis("left", "right") * H_SPEED
		if Input.get_axis("left", "right") == DIRECTIONS.RIGHT:
			facing = DIRECTIONS.RIGHT
		elif Input.get_axis("left", "right") == DIRECTIONS.LEFT:
			facing = DIRECTIONS.LEFT
	else:
		if velocity.x > 0:
			facing = DIRECTIONS.RIGHT
		elif velocity.x < 0:
			facing = DIRECTIONS.LEFT
	

	if mimic_original_collision:
		# The point of this absolute mess is to make it so that the player first moves vertically, then checks for collisions,
		# then moves horizontally, and checks again.
		# This makes things more accurate to the original IWBTG (example, jumping against a wall with a spike on top).
		# Not happy with this implementation though, and I'm still trying to find a more proper solution.
		# This also introduces a number of bugs
		
		var backup_vel
		var backup_vel2
		
		backup_vel = velocity
		velocity.x = 0
		move_and_slide() # Ignore xvel first
		on_floor = is_on_floor()
		on_ceiling = is_on_ceiling()
		_process_object_collisions() # Check collisions
		
		backup_vel2 = get_real_velocity() # Store this for later
		
		backup_vel.y = velocity.y
		velocity.x = backup_vel.x
		velocity.y = 0
		platform_floor_layers = 0 # Ignore platform movement during the second move_and_slide() call
		move_and_slide() # Ignore yvel now
		on_wall = is_on_wall()
		velocity.y = backup_vel.y
		_process_object_collisions()
		
		platform_floor_layers = 0xFFFFFFFF # Restore platform movement
		#if not on_floor and abs(backup_vel2.y) < 0.1:
			#velocity.y = backup_vel2.y
	else:
		move_and_slide()
		on_floor = is_on_floor()
		on_ceiling = is_on_ceiling()
		on_wall = is_on_wall()
		_process_object_collisions()
		if not on_floor and get_real_velocity().y == 0:
			velocity.y = get_real_velocity().y

	# Check for killers first
	for i in $AreaDetector.get_overlapping_areas():
		if i.is_in_group("killers"):
			kill_player()

	# Do a check for vines after moving so the animation plays better
	if vines.size() > 0 and is_on_wall_only():
		state = Globals.STATES.VINE
		facing = vines[0].facing
		_update_state_vine()
		return
	# Check for cylinder state as well
	if state == Globals.STATES.CYLINDER:
		_update_state_cylinder()
		return

	if on_floor and not was_on_floor and last_velocity.y > 400 and velocity.y == 0:
		for i in $JumpEffect.get_children():
			if i is CPUParticles2D:
				i.restart()
				i.emitting = true

	if on_floor:
		d_jump = true
		jumping = false

	if Input.is_action_just_pressed("jump"):
		if on_floor or platform_count > 0:
			velocity.y = S_JUMP_SPEED
			d_jump = true
			jumping = true
			Audio.play_sound("Jump")
		elif d_jump:
			velocity.y = D_JUMP_SPEED
			d_jump = false
			jumping = true
			for i in $DJumpEffect.get_children():
				if i is CPUParticles2D:
					i.restart()
					i.emitting = true
			$AnimationPlayer.stop() # Reset animation (e.g. twirl from springs)
			Audio.play_sound("DJump")
	
	if Input.is_action_just_released("jump") and velocity.y < 0 and jumping:
		velocity.y *= 0.45
	
	_handle_animation()
	_handle_shoot()
	
	was_on_floor = on_floor
	last_velocity = velocity


func _update_state_vine():
	velocity.y = VINE_SPEED + GRAVITY

	if Input.is_action_just_pressed("jump"):
		velocity.y = S_JUMP_SPEED
		velocity.x = H_SPEED * facing
		hlock = 3
		jumping = true
		state = Globals.STATES.DEFAULT
		Audio.play_sound("WallJump")

	if Input.get_axis("left", "right") == facing or is_on_floor():
		velocity.x = Input.get_axis("left", "right") * H_SPEED
		state = Globals.STATES.DEFAULT

	move_and_slide()
	_handle_shoot()

	$Sprite.flip_h = facing != DIRECTIONS.RIGHT
	$Bow.flip_h = facing != DIRECTIONS.RIGHT
	$AnimationPlayer.play("vine")


func _update_state_cylinder():
	$AnimationPlayer.stop()
	
	velocity.y = 0
	d_jump = true
	if not hlock:
		velocity.x = Input.get_axis("left", "right") * H_SPEED
	if velocity.x > 0:
		facing = DIRECTIONS.RIGHT
	elif velocity.x < 0:
		facing = DIRECTIONS.LEFT
	
	cylinder_timer += 0.101
	var cylinder_position = sin(cylinder_timer)
	
	if Input.is_action_just_pressed("jump"):
		state = Globals.STATES.DEFAULT
		if cylinder_position >= 0:
			velocity.y = S_JUMP_SPEED
		else:
			velocity.y = -S_JUMP_SPEED / 2
		cylinder_timer = 0
		current_cylinder = 0
		jumping = true
		Audio.play_sound("Jump")
		return
	else:
		var cylinder_offset = cylinder_position * (48 + 10.5) - 10.5
		position.y = current_cylinder.position.y - cylinder_offset
	
	move_and_slide()
	_handle_shoot()
	_handle_animation_cylinder()


func _update_state_dead():
	if timer > 0 or Input.is_action_pressed("teleport player"):
		var instance := load("res://Objects/Kid/BloodParticle.tscn")
		for i in 6:
			var id: AnimatableBody2D = instance.instantiate()
			get_parent().add_child(id)
			id.global_position = Vector2(global_position.x, global_position.y - 10)


func _update_state_warp():
	position = position.move_toward(target, 3)
	$AnimationPlayer.play("warp")


func _update_state_exit_warp():
	$Sprite.flip_h = facing != DIRECTIONS.RIGHT
	$StateTimer.wait_time = 0.18
	if $StateTimer.is_stopped():
		$StateTimer.start()
	next_state = Globals.STATES.DEFAULT
	$AnimationPlayer.play("exit_warp")


func _handle_shoot():
	if Input.is_action_just_pressed("shoot"):
		var instance := load("res://Objects/Kid/Bullet.tscn")
		var id: AnimatableBody2D = instance.instantiate()
		get_parent().add_child(id)
		id.facing = facing
		id.origin = self
		if state == Globals.STATES.VINE:
			id.global_position = Vector2(global_position.x, global_position.y - 5)
		else:
			id.global_position = Vector2(global_position.x, global_position.y - 10)
		Audio.play_sound("Shoot")


func _handle_animation():
	$Sprite.flip_h = facing != DIRECTIONS.RIGHT
	$Bow.flip_h = facing != DIRECTIONS.RIGHT
	if not on_floor:
		if $AnimationPlayer.current_animation != "twirl":
			if velocity.y >= 0:
				$AnimationPlayer.play("fall")
			else:
				$AnimationPlayer.play("jump")
	else:
		if Input.get_axis("left", "right") and on_floor:
			$AnimationPlayer.play("walk")
		else:
			$AnimationPlayer.play("idle")

func _handle_animation_cylinder():
	$Sprite.flip_h = facing != DIRECTIONS.RIGHT
	$Bow.flip_h = facing != DIRECTIONS.RIGHT
	$AnimationPlayer.stop() # Animate through code instead
	
	var cylinder_position = sin(cylinder_timer)
	var cylinder_anim_frame = 0
	if cos(cylinder_timer) > 0:
		z_index = -1
		if cylinder_position > 0.95:
			cylinder_anim_frame = 0
		elif cylinder_position > 0.6:
			cylinder_anim_frame = 11
		elif cylinder_position > 0.3:
			cylinder_anim_frame = 10
		elif cylinder_position > -0.3:
			cylinder_anim_frame = 9
		elif cylinder_position > -0.6:
			cylinder_anim_frame = 8
		elif cylinder_position > -0.95:
			cylinder_anim_frame = 7
		else:
			cylinder_anim_frame = 6
	else:
		z_index = 1
		if cylinder_position > 0.95:
			cylinder_anim_frame = 0
		elif cylinder_position > 0.6:
			cylinder_anim_frame = 1
		elif cylinder_position > 0.3:
			cylinder_anim_frame = 2
		elif cylinder_position > -0.3:
			cylinder_anim_frame = 3
		elif cylinder_position > -0.6:
			cylinder_anim_frame = 4
		elif cylinder_position > -0.95:
			cylinder_anim_frame = 5
		else:
			cylinder_anim_frame = 6
	
	cylinder_anim_frame += 21
	if Input.get_axis("left", "right"):
		cylinder_anim_frame += 12
	$Sprite.frame = cylinder_anim_frame
	


func kill_player():
	state = Globals.STATES.DEAD
	timer = 30
	$Sprite.hide()
	$Bow.hide()
	Audio.play_sound("Death")


# This function is called twice when "mimic_original_collision" is on
func _process_object_collisions():
	for i in get_slide_collision_count():
		var collider = get_slide_collision(i).get_collider()
		if collider.has_method("kid_collided"):
			collider.kid_collided(self, get_slide_collision(i))
		# Some objects might have the relevant script in their parent node..
		if collider.get_parent().has_method("kid_collided"):
			collider.get_parent().kid_collided(self, get_slide_collision(i))


func _on_area_detector_area_entered(area:Area2D):
	if area.is_in_group("killers") and state != Globals.STATES.DEAD:
		kill_player()
	if area.is_in_group("vines") and state != Globals.STATES.DEAD:
		vines.append(area)
		if is_on_wall_only():
			facing = area.facing
			state = Globals.STATES.VINE
			$AnimationPlayer.play("vine")


func _on_area_detector_area_exited(area):
	if area.is_in_group("vines") and state != Globals.STATES.DEAD:
		vines.erase(area)
		if vines.size() == 0:
			state = Globals.STATES.DEFAULT
	if area.is_in_group("cylinders") and state == Globals.STATES.CYLINDER:
		state = Globals.STATES.DEFAULT
		cylinder_timer = 0
	

func _on_area_detector_body_entered(body):
	if body.is_in_group("platforms"):
		platform_count += 1


func _on_area_detector_body_exited(body):
	if body.is_in_group("platforms"):
		platform_count -= 1


func _on_state_timer_timeout():
	state = next_state


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "twirl":
		$AnimationPlayer.play("fall")
