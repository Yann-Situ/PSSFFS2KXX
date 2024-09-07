## MultiStateMachine
# handle multiple current_states but with same logic:

## State System:
# # System
#
# The states of the state machine are nodes that can be coded to obtain the wanted behavior.
# Their functions (`enter`, `exit`, `process` and `physics_process`) are called by the state machine node.
#
# The connexions between states are controlled within the state code, depending on statuslogic variables and are supervised by the state machine in the `_process` and `physics_process` functions using a call to the `change_state` method.
#
# Statuslogic should manage the exterior dependencies and all the logic variables. It should also depend on a input controller to handle different behaviors.
#
# # Nodes
#
# - `State` (Node):
#
#     Handles the state of a character: run the appropriate animations, the
#         related functions and exit the state depending on the associated Status
#         Resources.
#     Four functions are called by the supervisor `StateMachine` node:
#     - `enter(previous_state : State = null) -> State`: called when entering this `State`.
#            If there is an immediate transition, return the next `State`, otherwise return `self` or `null`.
#     - `exit() -> void`: called just before entering the next `State`. Should not contain await or time stopping functions
#     - `process(delta) -> State`: called by the parent `StateMachine` during the `_process` call, after the `StatusLogic` `process` call.
#     - `physics_process(delta) -> State`: called by the parent `StateMachine` during the `_physics_process` call, after the `StatusLogic` `physics_process` call.
#
# - `StateMachine` (Node):
#
#     The `StateMachine` node links the `StatusLogic` to the `State` nodes:
#         it calls the `StatusLogic` process functions and handles the connexions between
#         different `State` nodes and contains a `current_state` variable to call
#         the appropriate process functions.
#
# - `StatusLogic` (Node):
#
#     `StatusLogic` handles and updates multiple boolean and `Status` resources and perform the logic
#         between them depending on the inputs from an `InputController` node.
#         `StatusLogic` often manages `Status` and `Trigger` Resources.
#
# - `InputController` (Node):
#
#     Manages the inputs. For a NPC, this can be done with code logic or
#         behaviour tree. For a playable character, use the `Input.event` to handle it.
#
# # Helpful Resources
#
# - `Status` (Resource):
#
#     Handles two bools related to a feature. For exemple a `Status` "jump" will
#         contain the bool `jump.is` to know if a Character is jumping and a bool
#         `jump.can` to know if it can jump.
#
# - `Trigger` (Resource):
#
#     Handles bools related to a button: `trigger.pressed`, `trigger.just_pressed`
#         and `trigger.just_release`.
@icon("res://assets/art/icons/state-machine-beige.png")
extends Node
class_name MultiStateMachine

@export var status_logic : StatusLogic #: set = set_status_logic, get = get_status_logic ##
@export var init_states : Array[State]
var current_states : Array[State]
var nb_machines : int
const MAX_STATE_TRANSITIONS : int = 20

func _ready():
	assert(status_logic != null)
	nb_machines = init_states.size()
	current_states = []
	current_states.resize(nb_machines)
	reset_states()

func process_machine(machine: int, delta : float):
	if !current_states[machine]:
		push_error("current_state["+str(machine)+"] is null")
		return
	var state : State = current_states[machine].process(delta)
	change_state(machine, state) # eventually change the state

func physics_process_machine(machine: int, delta : float):
	if !current_states[machine]:
		push_error("current_state["+str(machine)+" is null")
		return
	var state : State = current_states[machine].physics_process(delta)
	change_state(machine, state) # eventually change the state

func _process(delta):
	status_logic.process(delta)
	for machine in range(nb_machines):
		process_machine(machine, delta)

func _physics_process(delta):
	status_logic.physics_process(delta)
	for machine in range(nb_machines):
		physics_process_machine(machine, delta)

## Eventually change the state:
## if new_state is null or is equal to current_state, do nothing.
func change_state(machine : int, new_state : State):
	if new_state == null:
		push_error("new_state is null")
		return
	
	var i = 0
	while (new_state and new_state != current_states[machine] and i < MAX_STATE_TRANSITIONS):
		if current_states[machine]:
			current_states[machine].exit()
		var tmp = current_states[machine]
		current_states[machine] = new_state
		new_state = current_states[machine].enter(tmp)
		i = i+1
		# if current_state:
		# 	string += " -> " + current_state.name
	if i >= MAX_STATE_TRANSITIONS:
		push_error("change_state("+str(machine)+") more than MAX_STATE_TRANSITIONS in a change. "+\
			"The two last states were: "+str(current_states[machine])+" --- "+str(new_state))
	# if i > 0:
	# 	print(string)

## Reset the current_states to the init_states
func reset_states():
	for machine in range(nb_machines):
		reset_state(machine)

## Reset the current_state to the init_state of statemachine number machine
func reset_state(machine : int):
	if !init_states[machine]:
		push_error("init_state["+str(machine)+"] is null")
	change_state(machine, init_states[machine])
