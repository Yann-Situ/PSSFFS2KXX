extends Node

var playing = true
var list_of_physical_nodes = []
var mouse_ball = null #pointer to the last selectable item that called mouse_entered
var camera = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func toggle_playing():
	playing = !playing
	if playing :
		for n in list_of_physical_nodes:
			n.reset_position()
			n.enable_physics()
	else :
		for n in list_of_physical_nodes:
			n.disable_physics()
			n.reset_position()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
