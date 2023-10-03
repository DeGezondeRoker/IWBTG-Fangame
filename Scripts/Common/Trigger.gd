@tool
extends Area2D

## The sprite the block uses
@export var event_id := 0:
	set(new_id):
		event_id = new_id
		$Label.text = str(event_id)

func _ready():
	if not Engine.is_editor_hint():
		hide()

func _on_body_entered(body):
	if body.is_in_group("player"):
		Global.triggered_events.append(event_id)
