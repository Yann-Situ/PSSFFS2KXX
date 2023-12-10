extends TextBubble

@export_flags_2d_physics var collision_layer : int = 1 : set=set_collision_layer

func set_collision_layer(v : int):
	collision_layer = v
	$Area2D.collision_layer = collision_layer

## override the current behaviour
func display():
	$Area2D.set_deferred("monitoring", false)
	$SimpleBalloon.start(dialogue_resource, "title")

func _on_simple_balloon_dialogue_finished():
	$Area2D.set_deferred("monitoring", true)
