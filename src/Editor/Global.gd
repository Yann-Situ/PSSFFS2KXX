tool
extends Node

var playing = true
var list_of_physical_nodes = []
var mouse_ball = null #pointer to the last selectable item that called mouse_entered
var camera = null

var z_indices = {\
	"parallax_0" : 0, \
	"parallax_1" : 1, \
	"parallax_2" : 2, \
	"parallax_3" : 3, \
	"parallax_4" : 4, \
	"background_0" : 5, \
	"background_1" : 6, \
	"background_2" : 7, \
	"background_3" : 8, \
	"background_4" : 9, \
	"player_0" : 10, \
	"ball_0" : 11, \
	"player_1" : 12, \
	"foreground_0" : 15, \
	"foreground_1" : 16, \
	"foreground_2" : 17, \
	"foreground_3" : 18, \
	"foreground_4" : 19, \
	"foreparallax_0" : 20, \
	"foreparallax_1" : 21, \
	"foreparallax_2" : 22 \
}

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

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
	print("Toggle playing : "+str(playing))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
