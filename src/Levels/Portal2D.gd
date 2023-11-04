@icon("res://assets/art/icons/exit.png")
extends Node2D
class_name Portal2D

signal enter_portal_finished
signal exit_portal_finished

@export var activated : bool = true
@export var room: Room2D ## Room which contains this portal node.

enum PortalType {ENTRANCE, EXIT, BOTH, EXIT_LEVEL}
@export var portal_type : PortalType = PortalType.BOTH : set = set_portal_type

enum TriggerType {ON_BODY_ENTER, ON_INTERACTION, NO_TRIGGER}
@export var trigger_type : TriggerType = TriggerType.ON_BODY_ENTER : set = set_trigger_type

@export_global_file("*.tscn") var next_room : get = get_next_room, set = set_next_room
@export var next_room_portal : String : get = get_next_room_portal, set = set_next_room_portal

@export_group("Transition", "transition_")
@export var transition_color : Color = Color.BLACK : set = set_transition_color
@export_range(0.1, 10.0) var transition_speed : float = 1.0 : set = set_transition_speed

@onready var is_locked = false
var P = null # set in enter tree

func set_portal_type(new_type):
	portal_type = new_type
	if portal_type == PortalType.ENTRANCE or portal_type == PortalType.BOTH:
		pass # TO IMPLEMENT [TODO]
	if portal_type == PortalType.EXIT or \
		portal_type == PortalType.BOTH or \
		portal_type == PortalType.EXIT_LEVEL :
		if trigger_type == TriggerType.ON_BODY_ENTER:
			if $InteractionArea.handler_interacted.is_connected(self.interaction_exit_portal):
				$InteractionArea.handler_interacted.disconnect(self.interaction_exit_portal)
			if not $Area2D.body_entered.is_connected(self.area_body_exit_portal):
				$Area2D.body_entered.connect(self.area_body_exit_portal)
		elif trigger_type == TriggerType.ON_INTERACTION :
			if $Area2D.body_entered.is_connected(self.area_body_exit_portal):
				$Area2D.body_entered.disconnect(self.area_body_exit_portal)
			if not $InteractionArea.handler_interacted.is_connected(self.interaction_exit_portal):
				$InteractionArea.handler_interacted.connect(self.interaction_exit_portal)
		elif trigger_type == TriggerType.NO_TRIGGER :
			if $Area2D.body_entered.is_connected(self.area_body_exit_portal):
				$Area2D.body_entered.disconnect(self.area_body_exit_portal)
			if $InteractionArea.handler_interacted.is_connected(self.interaction_exit_portal):
				$InteractionArea.handler_interacted.disconnect(self.interaction_exit_portal)
			

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
	$AnimationPlayer.speed_scale = f

################################################################################
func disp(s:String):
	print(s)

#func _init():
#	print(name + " init")
#	room = self.get_parent().get_parent()
#	room.add_portal(self)

# to change
func _enter_tree():
	P = room.get_player()

func _ready():
	assert(is_instance_valid(room))
	assert(is_instance_valid(P))
	set_trigger_type(trigger_type)

################################################################################

func reload_portal():
	transition_out()
	await get_node("AnimationPlayer").animation_finished
	enter_portal()

func transition_in():
	#Transition.material.set("shader_parameter/center_offset", Vector2(0.0,0.0))
	$AnimationPlayer.play("transition_in")
	$AnimationPlayer.advance(0.0) # to avoid jitter issues

func transition_out():
	#var img = get_viewport().get_texture().get_data()
	#img.flip_y()
	#var screenshot = ImageTexture.new()
	#screenshot.create_from_image(img)
	#Transition.texture = screenshot
	#$Tween.follow_property(Transition.material, "shader_parameter/center_offset", \
	#	Global.camera.offset, Global.camera, "offset", 1.0)
	#$Tween.start()
	$AnimationPlayer.play("transition_out")
	$AnimationPlayer.advance(0.0) # to avoid jitter issues

func exit_portal():
	transition_out()
	P.S.disable_input()
	await get_node("AnimationPlayer").animation_finished
	exit_portal_finished.emit()

	if portal_type != PortalType.EXIT_LEVEL:
		room.exit_room(next_room, next_room_portal)
	else :
		room.exit_level(self.name)

# called when 
func enter_portal():
	P.set_start_position(self.global_position)
	P.reset_move()
	P.S.enable_input()
	transition_in()
	await get_node("AnimationPlayer").animation_finished
	exit_portal_finished.emit()

################################################################################

func area_body_exit_portal(body):
	# print_debug("enter portal "+name) # this function is called too many time due \
	# to the following issue : https://github.com/godotengine/godot/issues/14578
	if activated and !is_locked and body == P:
		exit_portal()

func interaction_exit_portal(interaction_handler):
	# print_debug("enter portal "+name) # this function is called too many time due \
	# to the following issue : https://github.com/godotengine/godot/issues/14578
	if activated and !is_locked :
		exit_portal()
