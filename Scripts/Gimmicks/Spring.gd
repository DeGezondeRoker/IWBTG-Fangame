@tool
extends AnimatableBody2D

# Bounce heights
const H_BOUNCE_SPEED := -670
const M_BOUNCE_SPEED := -525
const L_BOUNCE_SPEED := -375

enum POWERS {RED_SPRING, YELLOW_SPRING, GREEN_SPRING}
## Spring power
@export var power: POWERS:
	set(new_power):
		power = new_power
		match power:
			POWERS.RED_SPRING:
				$Sprite.frame = 0
				bounce_anim = "r_bounce"
				bounce_speed = H_BOUNCE_SPEED
			POWERS.YELLOW_SPRING:
				$Sprite.frame = 5
				bounce_anim = "y_bounce"
				bounce_speed = M_BOUNCE_SPEED
			POWERS.GREEN_SPRING:
				$Sprite.frame = 10
				bounce_anim = "g_bounce"
				bounce_speed = L_BOUNCE_SPEED
		
enum DIRECTIONS {UP, DOWN, LEFT, RIGHT}
## Spring direction
@export var direction: DIRECTIONS:
	set(new_direction):
		direction = new_direction
		match direction:
			DIRECTIONS.UP:
				rotation = 0
			DIRECTIONS.DOWN:
				rotation = deg_to_rad(180)
			DIRECTIONS.LEFT:
				rotation = deg_to_rad(270)
			DIRECTIONS.RIGHT:
				rotation = deg_to_rad(90)

@export var semi_solid := false
@export var twirl := false

var bounce_anim := "r_bounce"
var bounce_speed := H_BOUNCE_SPEED

func _ready():
	if semi_solid:
		$CollisionShape2D.set_deferred("disabled", true)


func _process(_delta):
	# Allow simply rotation the spring to change the direction
	match rad_to_deg(rotation):
		0:
			direction = DIRECTIONS.UP
		90:
			direction = DIRECTIONS.RIGHT
		180:
			direction = DIRECTIONS.DOWN
		270:
			direction = DIRECTIONS.LEFT

func kid_collided(kid:CharacterBody2D, collision:KinematicCollision2D):
	match direction:
			DIRECTIONS.UP:
				if kid.on_floor and collision.get_normal() == Vector2(0,-1):
					$AnimationPlayer.stop()
					$AnimationPlayer.play(bounce_anim)
					kid.velocity.y = bounce_speed
					kid.on_floor = false
					kid.d_jump = true
					kid.jumping = false
					if twirl:
						kid.get_node("AnimationPlayer").stop()
						kid.get_node("AnimationPlayer").play("twirl")
					Audio.play_sound("Spring")
			DIRECTIONS.DOWN:
				if kid.on_ceiling and collision.get_normal() == Vector2(0,1):
					$AnimationPlayer.stop()
					$AnimationPlayer.play(bounce_anim)
					kid.velocity.y = -bounce_speed
					kid.on_ceiling = false
					Audio.play_sound("Spring")
			DIRECTIONS.LEFT:
				if kid.on_wall and collision.get_normal() == Vector2(-1,0):
					$AnimationPlayer.stop()
					$AnimationPlayer.play(bounce_anim)
					kid.velocity.x = bounce_speed
					kid.hlock = 5
					kid.decelerate = 1
					Audio.play_sound("Spring")
			DIRECTIONS.RIGHT:
				if kid.on_wall and collision.get_normal() == Vector2(1,0):
					$AnimationPlayer.stop()
					$AnimationPlayer.play(bounce_anim)
					kid.velocity.x = -bounce_speed
					kid.hlock = 5
					kid.decelerate = -1
					Audio.play_sound("Spring")
