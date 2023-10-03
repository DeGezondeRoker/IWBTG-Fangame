extends Node

# Put all sounds in a single node/script. This makes it so that
# A. It is easier to play sounds (don't need to add a node and stuff)
# B. A sound can't play more than once at the same time. This makes spring spam way less annoying on the ears..

func play_sound(sfxName:String):
	if get_node_or_null(sfxName) is AudioStreamPlayer:
		get_node(sfxName).play()
	else:
		print("No such SFX exists..")
