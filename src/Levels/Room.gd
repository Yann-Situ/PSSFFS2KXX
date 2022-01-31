extends Node2D
class_name Room

signal exit_room
signal finish_room

onready var P = $Player
var portals = {}

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
			
func exit_room(next_room : String, next_room_portal : String):
	print_debug("exit "+self.name+" to enter "+next_room+" at the portal "+next_room_portal)
	if next_room == self.name:
		enter_room(next_room_portal)
	else:
		emit_signal("exit_room", next_room, next_room_portal)
	#get_tree().change_scene(next_room)
	#get_tree().reload_current_scene()

func enter_room(next_portal : String):
	if portals.has(next_portal):
		portals[next_portal].enter()
	else :
		printerr(next_portal+" not found in room "+self.name)
