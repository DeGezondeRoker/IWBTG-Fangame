extends Node2D

enum animationModes {NONE, JUMP_UP, JUMP_OUT}
## Player behaviour when coming out of this entrance
@export var animation: animationModes

func _ready():
	$Sprite.hide()
