tool
extends Node

var playing = true
var list_of_physical_nodes = []
var mouse_ball = null #pointer to the last selectable item that called mouse_entered
var camera = null

var z_indices = {\
	"parallax_0" : 00, \
	"parallax_1" : 10, \
	"parallax_2" : 20, \
	"parallax_3" : 30, \
	"parallax_4" : 40, \
	"background_0" : 50, \
	"background_1" : 60, \
	"background_2" : 70, \
	"background_3" : 80, \
	"background_4" : 90, \
	"character_0" : 100, \
	"character_1" : 110, \
	"player_0" : 120, \
	"ball_0" : 130, \
	"player_1" : 140, \
	"foreground_0" : 150, \
	"foreground_1" : 160, \
	"foreground_2" : 170, \
	"foreground_3" : 180, \
	"foreground_4" : 190, \
	"foreparallax_0" : 200, \
	"foreparallax_1" : 210, \
	"foreparallax_2" : 220 \
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
