@icon("res://assets/art/icons/level.png")
extends Node2D
class_name Level

#export (String) var dir_path = "res://src/Levels/LevelExample/"
#export var rooms # (Array, PackedScene)
@export_global_file("*.tscn") var first_room
@export var first_room_portal : String

var rooms = {} # map : name -> Room2D
var current_room_instance = null : set = set_current_room_instance
var player_scene = preload("res://src/Player/Player.tscn")
var meta_player = null
var player_save = null

func set_current_room_instance(room : Room2D):
	Global.set_current_room(room)
	current_room_instance = room

func _ready():
	load_level()
	enter_level()

func load_level():
	browse_rooms(first_room)

func browse_rooms(room_name : String):
	if !rooms.has(room_name) and room_name != "":
		var packed_room = load(room_name)
		if packed_room == null:
			printerr("can't preload "+room_name+" because it doesn't exist.")
			return

		var room: Room2D = packed_room.instantiate()
		rooms[room_name] = room
		print_debug("created room : "+room_name)
		room.meta_player = $Player.get_path() # instantiate meta_player for each room
		room.is_exiting_room.connect(self.change_room)
		room.is_exiting_level.connect(self.exit_level)

		# TODO ugly but we need to call _ready on room in order to get the portals...
		# Maybe find a system with resources ? Or store a meta room as resource, with its information
		# or maybe create an _init function that create the portal_list ?
		set_current_room_instance(room)
		self.add_child(room)
		var portal_nodes = room.get_portals().values()
		self.remove_child(room)

		for portal in portal_nodes:
			if portal.get_next_room():
				browse_rooms(portal.get_next_room())
			else :
				push_warning(portal.name+" doesn't have any value for next_room.")

################################################################################

func enter_level():
	Global.set_current_player($Player)
	change_room(first_room, first_room_portal)

func exit_level(exit_room : String, exit_room_portal : String):
	pass
	# not yet implemented
	# TODO: link with the menu hierarchy and all those not yet implemented stuff
	# don't forget to update current player
	print_debug("exit_level called on "+name+" on room "+exit_room+" at portal "+exit_room_portal)

func change_room(next_room : String, next_room_portal : String):
	print_debug("entering "+next_room+" at the portal "+next_room_portal)
	# TODO: pause or unpause the room when changing ?
	if self.is_ancestor_of(current_room_instance):
		self.remove_child(current_room_instance)
	if rooms.has(next_room):
		set_current_room_instance(rooms[next_room])

		# need to deal with the _ready problems... Maybe look for _init and _enter_tree
#		player_save = current_room_instance.get_node("Player")
#		current_room_instance.remove_child(player_save)
#		current_room_instance.add_child(meta_player)

		current_room_instance.enter_room(next_room_portal) #move it to the appropriate position
		self.add_child(current_room_instance)
	else :
		printerr(name+" doesn't have a preloaded room named "+next_room)
