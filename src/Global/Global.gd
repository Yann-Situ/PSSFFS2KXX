@tool
extends Node

@export var max_trail_points : int = 5000

var default_gravity = Vector2(0.0,ProjectSettings.get_setting("physics/2d/default_gravity")) # pix/s²
var gravity_alterer = AltererAdditive.new(default_gravity)
var cinematic_playing = false: set=set_cinematic_state, get=is_cinematic_playing
var camera : Camera2D = null : set = set_current_camera, get = get_current_camera
var current_room : Room2D = null : set = set_current_room, get = get_current_room
var current_player : Player = null : set = set_current_player, get = get_current_player

var playing = true
var list_of_physical_nodes = []
var mouse_ball = null #pointer to the last selectable item that called mouse_entered
var _nb_trail_points = 0

func can_add_trail_point() -> bool:
	return _nb_trail_points < max_trail_points
func add_trail_point() -> void:
	_nb_trail_points += 1
func remove_trail_point() -> void:
		_nb_trail_points -= 1

func set_cinematic_state(state : bool)->void:
	if state and !cinematic_playing:
		# start cinmeatic
		cinematic_playing = state
		if get_current_room():
			current_room.start_cinematic()
		if get_current_player():
			current_player.get_state_node().disable_input()
		print("cinematic starting")

	if !state and cinematic_playing:
		# stop cinematic
		cinematic_playing = state
		# stop cinematic shader
		if get_current_room():
			current_room.stop_cinematic()
		if get_current_player():
			current_player.get_state_node().enable_input()
		print("cinematic stopping")

func is_cinematic_playing()-> bool:
	return cinematic_playing
## start a cinematic: stop players input, use cinematic shader on camera and stop updating camera 
# in player's process.
func start_cinematic() -> void:
	if is_cinematic_playing():
		push_warning("cannot start because cinematic already playing")
		return
	set_cinematic_state(true)
## stop a cinematic: restore players input, unuse cinematic shader on camera and start reupdating camera 
# in player's process.
func stop_cinematic() -> void:
	if !is_cinematic_playing():
		push_warning("cannot stop because cinematic is not playing")
		return
	set_cinematic_state(false)

func set_current_camera(_camera : Camera2D):
	if _camera == null:
		push_error("camera is null")
	camera = _camera
func get_current_camera() -> Camera2D:
	if camera == null:
		push_error("camera is null")
	return camera
	
func set_current_room(room : Room2D):
	current_room = room
func get_current_room() -> Room2D:
	if current_room == null:
		push_error("current_room is null")
	return current_room
	
func set_current_player(player : Player):
	current_player = player
func get_current_player() -> Player:
	if current_player == null:
		push_error("current_player is null")
	return current_player

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
