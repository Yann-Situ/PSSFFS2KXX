extends Node2D
class_name Level

#export(Array, PackedScene) var rooms
export (String) var first_room
export (String) var first_room_portal

var rooms = {}
var actual_room_instance = null #

func _ready():
	pass # Replace with function body.

func preload_rooms():
	browse(first_room)

func browse_rooms(room_name : String):
	if !rooms.has(room_name):
		var packed_room = preload(room_name)
		if packed_room == null:
			printerr("can't preload "+room_name+" because it doesn't exist.")
			return

		var room: Room = packed_room.instance()
		rooms[room_name] = room

		var portal_nodes = room.get_portals().values()
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
	if self.has_child(actual_room_instance):
		self.remove_child(actual_room_instance)
	if rooms.has(next_room):
		actual_room_instance = rooms[next_room]
		self.add_child(actual_room_instance)
		actual_room_instance.enter_room(next_room_portal)
	else :
		printerr(name+" doesn't have a preloaded room named "+next_room)
