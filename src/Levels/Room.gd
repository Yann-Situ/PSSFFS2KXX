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
		printerr(next_portal+" not found in room "+self.name)
		return null

################################################################################

func _ready():
	var portal_list = get_node("Portals").get_children()
	for portal in portal_list:
		portals[portal.name] = portal

#	P = preload("res://src/Player/Player.tscn").instance()
#	P.name = "Player"
#	self.add_child(P)
#	if portals.has("PortalDefault"):
#		portals["PortalDefault"].enter()
#	else:
#		printerr(self.name+" doesn't have a PortalDefault portal for spawning Player")
#		if portal_list.count() < 1:
#			printerr(self.name+" doesn't have any Portal")
#			return
#		portal_list[0].enter()


func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_R:
			P.reset_move()

################################################################################

func exit_room(next_room : String, next_room_portal : String):
	print_debug("exit "+self.name+" to enter "+next_room+" at the portal "+next_room_portal)
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
