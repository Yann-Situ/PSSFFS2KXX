extends Node2D
class_name Level

#export (String) var dir_path = "res://src/Levels/LevelExample/"
#export(Array, PackedScene) var rooms
export (String, FILE, "*.tscn") var first_room
export (String) var first_room_portal

var rooms = {}
var actual_room_instance = null #

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

		var room: Room = packed_room.instance()
		rooms[room_name] = room
		print_debug("add room : "+room_name)
		room.connect("exit_room", self, "change_room")
		room.connect("exit_level", self, "exit_level")
		
		# TODO ugly but we need to call _ready on room in order to get the portals...
		self.add_child(room)
		var portal_nodes = room.get_portals().values()
		self.remove_child(room)
		
		for portal in portal_nodes:
			browse_rooms(portal.get_next_room())

func enter_level():
	change_room(first_room, first_room_portal)

func exit_level(exit_room : String, exit_room_portal : String):
	pass
	# not yet implemented
	# TODO
	print_debug("exit_level called on "+name+" on room "+exit_room+" at portal "+exit_room_portal)

func change_room(next_room : String, next_room_portal : String):
	print_debug("entering "+next_room+" at the portal "+next_room_portal)
	
	if self.is_a_parent_of(actual_room_instance):
		self.remove_child(actual_room_instance)
	if rooms.has(next_room):
		actual_room_instance = rooms[next_room]
		actual_room_instance.enter_room(next_room_portal)
		self.add_child(actual_room_instance)
	else :
		printerr(name+" doesn't have a preloaded room named "+next_room)
