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
@icon("res://assets/art/icons/settings-beige.png")
extends Resource
class_name StatusLogic

@export var input_controller : InputController #: set = set_input_controller, get = get_input_controller ##

var status_dict : Dictionary = {} : get = get_status_dict
var trigger_dict : Dictionary = {} : get = get_trigger_dict

func get_status_dict():
	return status_dict
func get_trigger_dict():
	return trigger_dict

func _init():
	var properties = get_property_list()
	# properties is an array of dictionaries with:
	# 'name' is the property's name, as a String;
	# 'class_name' is an empty StringName, unless the property is @GlobalScope.TYPE_OBJECT and it inherits from a class;
	# 'type' is the property's type, as an int (see Variant.Type);
	# 'hint' is how the property is meant to be edited (see PropertyHint);
	# 'hint_string' depends on the hint (see PropertyHint);
	# 'usage' is a combination of PropertyUsageFlags.
	for property in properties:
		# TODO Wait for Godot 4.3 and get_global_name, or a rework of is_class:
		# https://github.com/godotengine/godot/pull/80487
		# https://github.com/godotengine/godot/issues/21789
		## Workaround that only works for variables with predefined values:
		var v = self.get(property["name"])
		if v is Status:
			status_dict[v._name] = v
		elif v is Trigger:
			trigger_dict[v._name] = v

## function that takes a State node and link its required status to this StatusLogic
## Status resources. This function is called by the StateMachine at the initialization.
func link_status_to_state(state : State):
	var requirements = state.get_status_requirements()
	for status_variable_name in requirements:
		var variable = state.get(status_variable_name)
		if status_dict.has(variable._name):
			state.set(status_variable_name, status_dict[variable._name])
		else :
			push_warning(variable._name+" is not the _name of a Status")

## function that takes a State node and link its required trigger to the input_controller
## Trigger resources. This function is called by the StateMachine at the initialization.
func link_trigger_to_state(state : State):
	var requirements = state.get_trigger_requirements()
	for trigger_variable_name in requirements:
		var variable = state.get(trigger_variable_name)
		if trigger_dict.has(variable._name):
			state.set(trigger_variable_name, trigger_dict[variable._name])
		else :
			push_warning(variable._name+" is not the _name of a Trigger")

## Called by the parent StateMachine during the _physics_process call, before
## the State nodes physics_process calls.
func process(delta):
	return

## Called by the parent StateMachine during the _physics_process call, before
## the State nodes physics_process calls.
func physics_process(delta):
	return

## update the triggers from the input_controller Node.
func update_triggers():
	input_controller.update_triggers()

## update the status using logic.
func update_status():
	pass
