extends TextBubble

## override the current behaviour
func display():
	$InteractionArea.enabled = false
	$SimpleBalloon.start(dialogue_resource, "title")

func _on_simple_balloon_dialogue_finished():
	$InteractionArea.enabled = true
