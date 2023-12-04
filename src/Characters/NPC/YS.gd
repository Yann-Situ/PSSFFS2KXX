extends Node2D

@export var dialogue_resource : DialogueResource ## dialogue to trigger
@export var dialogue_title : String : set=set_dialogue_title ## title in the dialogue resource
func set_dialogue_title(v : String):
	dialogue_title = v
# Called when the node enters the scene tree for the first time.
func _ready():
	$InteractionArea.enter = Callable(self, "set_modulate").bind(Color.PLUM)
	$InteractionArea.exit = Callable(self, "set_modulate").bind(Color.WHITE)

func interaction(interaction_handler):
	GlobalEffect.make_impact(global_position)
	$InteractionArea.enabled = false
	$Balloon.start(dialogue_resource, dialogue_title, [self])

func _on_balloon_pop_finished():
	$InteractionArea.enabled = true
