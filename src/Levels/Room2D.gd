@tool
@icon("res://assets/art/icons/house.png")
extends Node2D
class_name Room2D

signal is_exiting_room
signal is_exiting_level

@export var using_new_player : bool = true

@export var limit_left : int = -10000000 # : set = set_limit_left
@export var limit_top : int = -10000000 # : set = set_limit_top
@export var limit_right : int = 10000000 # : set = set_limit_right
@export var limit_bottom : int = 10000000 # : set = set_limit_bottom

#func set_limit_left(v):
#	limit_left = v
#	print("OKLEFT")
#	if Engine.is_editor_hint():
#		print("OKLEFT2")
#		queue_redraw()
#func set_limit_top(v):
#	limit_top = v
#	if Engine.is_editor_hint():
#		queue_redraw()
#func set_limit_right(v):
#	limit_right = v
#	if Engine.is_editor_hint():
#		queue_redraw()
#func set_limit_bottom(v):
#	limit_bottom = v
#	if Engine.is_editor_hint():
#		queue_redraw()

var P = null # Player, set in enter_tree
var portals : Dictionary = {} : get = get_portals

@export var meta_player : NodePath ## sould be set by the upper level

func _draw():
	if not Engine.is_editor_hint():
		return
	draw_rect(Rect2(limit_left,limit_top,limit_right-limit_left,limit_bottom-limit_top),Color.DEEP_PINK, false, 4.0)
func _process(_delta : float)->void: # set_process(false) is called when not in editor
	queue_redraw()

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
	if Engine.is_editor_hint():
		return
	# check if it has a Player node as a child. If not, create a Player node
	# and assign it to meta_player
	print(name + " enter_tree")
	#print("METAPLAYER : " + str(meta_player))
	if not has_node(meta_player): # when room is run alone from the editor for tests
		#print("No meta player : create one and assign meta_player")
		Global.set_current_room(self)
		var player_scene = null
		if using_new_player:
			player_scene = load("res://src/Characters/Player/NewPlayer.tscn")
		else:
			player_scene = load("res://src/Player/Player.tscn")
		var player = player_scene.instantiate()
		self.add_child(player) #move it to the appropriate position
		meta_player = player.get_path()
		Global.set_current_player(player)
		#print("---> new METAPLAYER : " + str(meta_player))
		if self.has_node("PlayerPosition"):
			player.global_position = get_node_or_null("PlayerPosition").position
	P = get_player()
	assert(is_instance_valid(P))

func _ready():
	if Engine.is_editor_hint():
		set_process(true) # to enable draw
		return
	set_process(false)
	print(name + " ready")
	var portal_list = get_node("Portals").get_children() #TODO look for a better way to list Portals
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
	portal.enter_portal_finished.connect(self.unlock_portals) # TODO maybe use groups instead of having the room managing the locking of portals.
	portal.exit_portal_finished.connect(self.lock_portals)

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_R:
			P.reset_move()

################################################################################

func exit_room(next_room : String, next_room_portal : String):
	if next_room == self.name:
		enter_room(next_room_portal)
	else:
		is_exiting_room.emit(next_room, next_room_portal)
	#get_tree().change_scene_to_file(next_room)
	#get_tree().reload_current_scene()

func exit_level(exit_portal : String):
	is_exiting_level.emit(self.name, exit_portal)

func enter_room(entrance_portal : String):
	update_camera_limit()
	if portals.has(entrance_portal):
		portals[entrance_portal].enter_portal()
	else :
		printerr(entrance_portal+" not found in room "+self.name)

################################################################################

func start_cinematic():
	$RoomAnimations.play("start_cinematic")
func stop_cinematic():
	$RoomAnimations.play("stop_cinematic")
