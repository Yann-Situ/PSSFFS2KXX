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
@icon("res://assets/art/icons/state-machine-beige.png")
extends Node
class_name StateMachine

@export var status_logic : StatusLogic #: set = set_status_logic, get = get_status_logic ##
@export var init_state : State : set=set_init_state
var current_state : State : set=change_state
const MAX_STATE_TRANSITIONS : int = 20

func set_init_state(s : State):
	init_state = s

func _ready():
	assert(status_logic != null)
	for child in get_children():
		if child is State:
			status_logic.link_status_to_state(child)
			status_logic.link_trigger_to_state(child)
		#else:
		#	push_warning(child.name+" is not a State node.") # no problem if it is not a State
	reset_state()

func _process(delta):
	if !current_state:
		push_error("current_state is null")
		return
	status_logic.process(delta)
	var state : State = current_state.process(delta)
	change_state(state) # eventually change the state

func _physics_process(delta):
	if !current_state:
		push_error("current_state is null")
		return
	status_logic.physics_process(delta)
	var state : State = current_state.physics_process(delta)
	change_state(state) # eventually change the state

## Eventually change the state:
## if new_state is null or is equal to current_state, do nothing.
func change_state(new_state : State):
	var i = 0
	# var string = "  | "
	# if current_state:
	# 	string += current_state.name
	while (new_state and new_state != current_state and i < MAX_STATE_TRANSITIONS):
		if current_state:
			current_state.exit()
		var tmp = current_state
		current_state = new_state
		new_state = current_state.enter(tmp)
		i = i+1
		# if current_state:
		# 	string += " -> " + current_state.name
	if i >= MAX_STATE_TRANSITIONS:
		push_error("change states more than MAX_STATE_TRANSITIONS in a change")
	# if i > 0:
	# 	print(string)

## Reset the current_state to the init_state
func reset_state():
	if !init_state:
		push_error("init_state is null")
	change_state(init_state)
