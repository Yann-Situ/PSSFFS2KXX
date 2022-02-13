extends Node2D
class_name Room

signal exit_room
signal exit_level

onready var P = $Player
var portals = {} setget , get_portals

func get_portals():
	return portals
func get_portal(portal_name : String):
	if portals.has(portal_name):
		return portals[portal_name]
	else :
		printerr(portal_name+" not found in room "+self.name)
		return null

func lock_portals(): # necessary because of issue : https://github.com/godotengine/godot/issues/14578
	for portal in portals.values():
		portal.is_locked = true
		
func unlock_portals(): # necessary because of issue : https://github.com/godotengine/godot/issues/14578
	for portal in portals.values():
		portal.is_locked = false
################################################################################

	
func _ready():
	var portal_list = get_node("Portals").get_children()
	for portal in portal_list:
		portals[portal.name] = portal
		portal.connect("enter_portal_finished", self, "unlock_portals")
		portal.connect("exit_portal_finished", self, "lock_portals")
	lock_portals()

#	P = preload("res://src/Player/Player.tscn").instance()
#	P.name = "Player"
#	self.add_child(P)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_R:
			P.reset_move()

################################################################################

func exit_room(next_room : String, next_room_portal : String):
	if next_room == self.name:
		enter_room(next_room_portal)
	else:
		emit_signal("exit_room", next_room, next_room_portal)
	#get_tree().change_scene(next_room)
	#get_tree().reload_current_scene()

func exit_level(exit_portal : String):
	emit_signal("exit_level", self.name, exit_portal)

func enter_room(entrance_portal : String):
	if portals.has(entrance_portal):
		portals[entrance_portal].enter_portal()
	else :
		printerr(entrance_portal+" not found in room "+self.name)
