extends Node2D

@export var dialogue_resource : DialogueResource ## dialogue to trigger
@export var dialogue_title : String ## title in the dialogue resource
# Called when the node enters the scene tree for the first time.
func _ready():
	$InteractionArea.enter = Callable(self, "set_modulate").bind(Color.PLUM)
	$InteractionArea.exit = Callable(self, "set_modulate").bind(Color.WHITE)

func interaction(interaction_handler):
	GlobalEffect.make_impact(global_position)
	$PopBalloon.start(dialogue_resource, dialogue_title)
	print("YS IMPACT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

