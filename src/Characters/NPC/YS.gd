extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$InteractionArea.interact = Callable(self, "interaction")
	$InteractionArea.enter = Callable(self, "set_modulate").bind(Color.PLUM)
	$InteractionArea.exit = Callable(self, "set_modulate").bind(Color.WHITE)

func interaction():
	GlobalEffect.make_impact(global_position)
	print("YS IMPACT")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

