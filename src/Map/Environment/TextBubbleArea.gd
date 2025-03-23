extends TextBubble

@export_flags_2d_physics var collision_mask : int = 1 : set=set_collision_mask

func set_collision_mask(v : int):
	collision_mask = v
	$Area2D.collision_mask = collision_mask

## override the current behaviour
func display():
	$Area2D.set_deferred("monitoring", false)
	$SimpleBalloon.start(dialogue_resource, "title")

func _on_simple_balloon_dialogue_finished():
	$Area2D.set_deferred("monitoring", true)
