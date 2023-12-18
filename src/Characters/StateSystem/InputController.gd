## State System:
##     6 objects:
##     Status (Resource):
##         Handles bools related to a feature. For exemple a Status "jump" will
##         contain the bool jump.is to know if a Character is jumping and a bool
##         jump.can to know if it can jump.
##     Trigger (Resource):
##         Handles bools related to a button: trigger.pressed, trigger.just_pressed
##         and trigger.just_release.
##     State (Node):
##         Handles the state of a character: run the appropriate animations, the
##         related functions and exit the state depending on the associated Status
##         Resources.
##         State should be a child of a StateMachine Node.
##     StateMachine (Node):
##         The StateMachine node links the StatusLogic to the State nodes:
##         it calls the StatusLogic process functions and handles the connexions between
##         different State nodes and contains a "current_state" variable to call
##         the appropriate process functions.
##     StatusLogic (Resource):
##         StatusLogic handles and updates multiple Status resources and perform the logic
##         between them depending on the inputs from an InputController Resource.
##         StatusLogic also manages the link between the Status and Trigger Resources
##         and the Status and Trigger requirements of the State nodes. # TODO maybe change this behaviour?
##     InputController (Node):
##         Manages the inputs. For a NPC, this can be done with code logic or
##         behaviour tree. For a playable character, use the Input.event to handle it.
#         behaviour tree. For a playable character, use the Input.event to handle it.
@icon("res://assets/art/icons/joystick-beige.png")
extends Node
class_name InputController

var right : Trigger = Trigger.new("right")
var left : Trigger = Trigger.new("left")
var up : Trigger = Trigger.new("up")
var down : Trigger = Trigger.new("down")
var select : Trigger = Trigger.new("select")
var accept : Trigger = Trigger.new("accept")
var power : Trigger = Trigger.new("power")
var release : Trigger = Trigger.new("release")
var interact : Trigger = Trigger.new("interact")

func update_triggers():
	pass

# func _input(event):
#     pass
