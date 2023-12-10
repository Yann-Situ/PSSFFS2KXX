@icon("res://assets/art/icons/speech-bubble.png")
extends Node2D
class_name TextBubble

@export_multiline var text : String : set=set_text ## title in the dialogue resource
@export var one_shot : bool = false : set=set_one_shot ## if true, called queue free after on dialogue_finished
@export var seconds_per_character : float = 0.03 : set=set_seconds_per_character ## seconds per character when typing the text
@onready var dialogue_resource = DialogueManager.create_resource_from_text("~ title\n"+text)

func set_text(v : String):
	text = v
	dialogue_resource = DialogueManager.create_resource_from_text("~ title\n"+text)

func set_one_shot(v : bool):
	one_shot = v
	if not one_shot and $SimpleBalloon.dialogue_finished.is_connected(self.queue_free):
		$SimpleBalloon.dialogue_finished.disconnect(self.queue_free)
	if one_shot and not $SimpleBalloon.dialogue_finished.is_connected(self.queue_free):
		$SimpleBalloon.dialogue_finished.connect(self.queue_free)

func set_seconds_per_character(v : float):
	seconds_per_character = v
	$SimpleBalloon.seconds_per_character = seconds_per_character

func _ready():
	if $SimpleBalloon == null:
		push_error("child SimpleBallon is null")
		queue_free()

################################################################################

func display():
	$SimpleBalloon.start(dialogue_resource, "title")
