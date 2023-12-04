extends Node2D

@export_multiline var text : String : set=set_text ## title in the dialogue resource
@onready var dialogue_resource = DialogueManager.create_resource_from_text("~ title\n"+text)

func set_text(v : String):
	text = v
	dialogue_resource = DialogueManager.create_resource_from_text("~ title\n"+text)
	
func interaction(interaction_handler):
	$InteractionArea.enabled = false
	$Balloon.start(dialogue_resource, "title")


func _on_balloon_pop_finished():
	$InteractionArea.enabled = true
