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
@icon("res://assets/art/icons/triangle-beige.png")
extends Resource
class_name Trigger

@export var _name : String = "" #: set = set_name, get = get_name
var pressed : bool = false : set = set_pressed#, get = get_pressed
var just_pressed : bool = false : set = set_just_pressed#, get = get_just_pressed
var just_released : bool = false : set = set_just_released#, get = get_just_released

var _locked : bool = false

func _init(s : String, _pressed = false, _just_pressed = false, _just_released = false):
	_name = s
	pressed =_pressed
	just_pressed =_just_pressed
	just_released =_just_released

func set_pressed(b : bool):
	if _locked:
		push_warning("pressed not modified because the Trigger is locked")
		return
	pressed = b

func set_just_pressed(b : bool):
	if _locked:
		push_warning("just_pressed not modified because the Trigger is locked")
		return
	just_pressed = b

func set_just_released(b : bool):
	if _locked:
		push_warning("just_released not modified because the Trigger is locked")
		return
	just_released = b

func set_from_input_action(action_name : String):
	if !InputMap.has_action(action_name):
		push_error("no action named '"+action_name+"'")
		return
	pressed = Input.is_action_pressed(action_name)
	just_pressed = Input.is_action_just_pressed(action_name)
	just_released = Input.is_action_just_released(action_name)

func lock():
	_locked = true

func unlock():
	_locked = false
