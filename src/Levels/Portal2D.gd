extends Node2D
class_name Portal2D

signal enter_portal_finished
signal exit_portal_finished

@export (bool) var activated = true

enum PortalType {ENTRANCE, EXIT, BOTH, EXIT_LEVEL}
@export (PortalType) var portal_type = PortalType.BOTH : set = set_portal_type

enum TriggerType {ON_BODY_ENTER, ON_KEY_E}
@export (TriggerType) var trigger_type = TriggerType.ON_BODY_ENTER : set = set_trigger_type

@export (String,FILE, "*.tscn") var next_room : get = get_next_room, set = set_next_room
@export (String) var next_room_portal : get = get_next_room_portal, set = set_next_room_portal

@export (Color) var transition_color = Color.BLACK : set = set_transition_color
@export (float, EXP, 0.1, 10.0) var transition_speed = 1.0 : set = set_transition_speed

var room = null
@onready var is_locked = false 
var P = null

func set_portal_type(new_type):
	portal_type = new_type
	if portal_type == PortalType.ENTRANCE or portal_type == PortalType.BOTH:
		pass # TO IMPLEMENT [TODO]
	if portal_type == PortalType.EXIT or \
	   portal_type == PortalType.BOTH or \
   	   portal_type == PortalType.EXIT_LEVEL :
		if trigger_type == TriggerType.ON_BODY_ENTER:
			$Area2D.connect("body_entered",Callable(self,"_on_Area2D_body_entered"))
		elif trigger_type == TriggerType.ON_KEY_E :
			pass # TO IMPLEMENT [TODO]

func set_trigger_type(new_type):
	trigger_type = new_type
	set_portal_type(portal_type)

func set_next_room(_next_room : String):
	next_room = _next_room

func set_next_room_portal(_next_room_portal : String):
	next_room_portal = _next_room_portal

func get_next_room():
	return next_room

func get_next_room_portal():
	return next_room_portal

func set_transition_color(c : Color):
	transition_color = c
	$CanvasLayer/Transition_in.color = c
	$CanvasLayer/Transition_out.color = c

func set_transition_speed(f : float):
	transition_speed = f
	$AnimationPlayer.playback_speed = f

################################################################################
func disp(s:String):
	print(s)

#func _init():
#	print(name + " init")
#	room = self.get_parent().get_parent()
#	room.add_portal(self)
	
func _enter_tree():
	room = get_parent().get_parent()
	P = room.get_player()

func _ready():
	set_trigger_type(trigger_type)

################################################################################

func reload_portal():
	transition_out()
	await get_node("AnimationPlayer").animation_finished
	enter_portal()

func transition_in():
	#Transition.material.set("shader_param/center_offset", Vector2(0.0,0.0))
	$AnimationPlayer.play("transition_in")
	$AnimationPlayer.advance(0.0) # to avoid jitter issues

func transition_out():
	#var img = get_viewport().get_texture().get_data()
	#img.flip_y()
	#var screenshot = ImageTexture.new()
	#screenshot.create_from_image(img)
	#Transition.texture = screenshot
	#$Tween.follow_property(Transition.material, "shader_param/center_offset", \
	#	Global.camera.offset, Global.camera, "offset", 1.0)
	#$Tween.start()
	$AnimationPlayer.play("transition_out")
	$AnimationPlayer.advance(0.0) # to avoid jitter issues

func exit_portal():
	transition_out()
	P.S.disable_input()
	await get_node("AnimationPlayer").animation_finished
	emit_signal("exit_portal_finished")
	
	if portal_type != PortalType.EXIT_LEVEL:
		room.exit_room(next_room, next_room_portal)
	else :
		room.exit_level(self.name)

func enter_portal():
	P.set_start_position(self.global_position)
	P.reset_move()
	P.S.enable_input()
	transition_in()
	await get_node("AnimationPlayer").animation_finished
	emit_signal("enter_portal_finished")

################################################################################

func _on_Area2D_body_entered(body):
	# print_debug("enter portal "+name) # this function is called too many time due \
	# to the following issue : https://github.com/godotengine/godot/issues/14578
	if activated and !is_locked and body == P:
		exit_portal()
		
