extends Node2D
class_name Portal2D

enum PortalType {ENTRANCE, EXIT, BOTH}
export (PortalType) var portal_type = PortalType.BOTH setget set_portal_type

enum TriggerType {ON_BODY_ENTER, ON_KEY_E}
export (TriggerType) var trigger_type = TriggerType.ON_BODY_ENTER setget set_trigger_type

export (String) var next_room
export (String) var next_room_portal

onready var room = get_parent().get_parent()
onready var P = room.get_node("Player")

func set_portal_type(new_type):
	print("set_portal_type")
	portal_type = new_type
	if portal_type == PortalType.ENTRANCE or portal_type == PortalType.BOTH:
		pass
	if portal_type == PortalType.EXIT or portal_type == PortalType.BOTH:
		if trigger_type == TriggerType.ON_BODY_ENTER:
			$Area2D.connect("body_entered", self, "_on_Area2D_body_entered")
		elif trigger_type == TriggerType.ON_KEY_E :
			pass # TO IMPLEMENT [TODO]
			
func set_trigger_type(new_type):
	trigger_type = new_type
	set_portal_type(portal_type)
################################################################################
func disp(s:String):
	print(s)

func _ready():
	set_trigger_type(trigger_type)

################################################################################

func reload_portal():
	transition_out()
	yield(get_node("AnimationPlayer"), "animation_finished")
	enter()

func transition_in():
	#Transition.material.set("shader_param/center_offset", Vector2(0.0,0.0))
	$AnimationPlayer.play("transition_in")

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

func exit():
	transition_out()
	P.S.disable_input()
	yield(get_node("AnimationPlayer"), "animation_finished")
	room.exit_room(next_room, next_room_portal)
	
func enter():
	P.set_start_position(self.global_position)
	P.reset_move()
	P.S.enable_input()
	transition_in()

################################################################################

func _on_Area2D_body_entered(body):
	if body == P:
		exit()
