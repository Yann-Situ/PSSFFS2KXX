extends Node2D
class_name Room2D

signal exit_room
signal exit_level

export (int) var limit_left = -10000000
export (int) var limit_top = -10000000
export (int) var limit_right = 10000000
export (int) var limit_bottom = 10000000

var P = null
var portals = {} setget , get_portals

export (NodePath) var meta_player # sould be set by the level

func update_camera_limit():
	P.Camera.limit_left = limit_left
	P.Camera.limit_top = limit_top
	P.Camera.limit_right = limit_right
	P.Camera.limit_bottom = limit_bottom

func get_portals():
	return portals
func get_portal(portal_name : String):
	if portals.has(portal_name):
		return portals[portal_name]
	else :
		printerr(portal_name+" not found in room "+self.name)
		return null

func get_player():
	return get_node(meta_player)

func lock_portals(): # necessary because of issue : https://github.com/godotengine/godot/issues/14578
	for portal in portals.values():
		portal.is_locked = true

func unlock_portals(): # necessary because of issue : https://github.com/godotengine/godot/issues/14578
	for portal in portals.values():
		portal.is_locked = false
################################################################################

func _enter_tree():
	# check if it has a Player node as a child. If not, create a Player node 
	# and assign it to meta_player
	print(name + " enter_tree")
	#print("METAPLAYER : " + str(meta_player))
	if get_node(meta_player) == null: # when room is run alone from the editor for tests
		#print("No meta player : create one and assign meta_player")
		Global.set_current_room(self)
		var player_scene = load("res://src/Player/Player.tscn")
		var player = player_scene.instance()
		self.add_child(player) #move it to the appropriate position
		meta_player = player.get_path()
		#print("---> new METAPLAYER : " + str(meta_player))
		if self.has_node("PlayerPosition"):
			player.global_position = get_node_or_null("PlayerPosition").global_position
	P = get_player()
	
func _ready():
	print(name + " ready")
	var portal_list = get_node("Portals").get_children()
	for portal in portal_list:
		add_portal(portal)
		# note that if room isn't a child of level (like when it is opened from
		# the editor as child of root), enter_room is never called so 
		# enter_portal_finished is never emited and all the portals are locked.
	
	if self.has_node("PlayerPosition"):
		get_node_or_null("PlayerPosition").visible = false
	lock_portals()
	
	if get_parent() == get_tree().root:
		update_camera_limit()

func add_portal(portal : Portal2D):
	portals[portal.name] = portal
	portal.connect("enter_portal_finished", self, "unlock_portals")
	portal.connect("exit_portal_finished", self, "lock_portals")
		

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
	update_camera_limit()
	if portals.has(entrance_portal):
		portals[entrance_portal].enter_portal()
	else :
		printerr(entrance_portal+" not found in room "+self.name)
