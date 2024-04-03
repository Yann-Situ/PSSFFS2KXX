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
@icon("res://assets/art/icons/circle-beige.png") # https://www.iconsdb.com/icon-sets/vintage-paper-icons/circle-outline-icon.html
extends Node
class_name State

# var status_required : Array[String] = [] #: set = set_status_required, get = get_status_required ##
# @export var status : Status #: set = set_status, get = get_status ##
# var trigger_required : Array[String] = [] #: set = set_trigger_required, get = get_trigger_required ##
# @export var trigger : Status #: set = set_trigger, get = get_trigger ##

## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	return self

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit() -> void:
	pass

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	return self

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	return self

# OUTDATED:
# ## return the an array[string] of Status variable names that are required by this
# ## State node.
# func get_status_requirements() -> Array[String]:
# 	var properties = get_property_list()
# 	# properties is an array of dictionaries with:
# 	# 'name' is the property's name, as a String;
# 	# 'class_name' is an empty StringName, unless the property is @GlobalScope.TYPE_OBJECT and it inherits from a class;
# 	# 'type' is the property's type, as an int (see Variant.Type);
# 	# 'hint' is how the property is meant to be edited (see PropertyHint);
# 	# 'hint_string' depends on the hint (see PropertyHint);
# 	# 'usage' is a combination of PropertyUsageFlags.
# 	var requirements : Array[String] = []
# 	for property in properties:
# 		# if property["class_name"] == "Status": # doesn't work for some reason
# 		# 	requirements.push_back(property["name"])
# 		# TODO Wait for Godot 4.3 and get_global_name, or a rework of is_class:
# 		# https://github.com/godotengine/godot/pull/80487
# 		# https://github.com/godotengine/godot/issues/21789
# 		## Workaround that only works for exported variables:
# 		# if property["hint_string"] == "Trigger":
# 		# 	requirements.push_back(property["name"])
# 		## Workaround that only works for variables with predefined values:
# 		if self.get(property["name"]) is Status:
# 			requirements.push_back(property["name"])
# 	return requirements
#
# ## return the an Array[string] of Trigger variable names that are required by this
# ## State node. See get_status_requirements() code for some current issues on this implementation
# func get_trigger_requirements():
# 	var properties = get_property_list()
# 	var requirements : Array[String] = []
# 	for property in properties:
# 		if self.get(property["name"]) is Trigger:
# 			requirements.push_back(property["name"])
# 	return requirements
