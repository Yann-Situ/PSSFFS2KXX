extends StateMachine
class_name ReplacementStateMachine

var state_map : Dictionary = {} ## keys are node to replace and values are replacement nodes.

## Eventually change the state:
## if new_state is null or is equal to current_state, do nothing.
func change_state(new_state : State):
	if state_map.has(new_state):
		new_state = state_map[new_state]

	var i = 0
	while (new_state and new_state != current_state and i < MAX_STATE_TRANSITIONS):
		if current_state:
			current_state.exit()
		var tmp = current_state
		current_state = new_state
		new_state = current_state.enter(tmp)
		if state_map.has(new_state):
			new_state = state_map[new_state]
		i = i+1
	if i >= MAX_STATE_TRANSITIONS:
		push_error("change states more than MAX_STATE_TRANSITIONS in a change")

func reset_map() -> void:
	state_map.clear()

func is_mapped(state : State) -> bool:
	return state_map.has(state)

func map(replaced_state : State, replacement_state : State) -> void:
	state_map[replaced_state] = replacement_state

func unmap(state : State) -> void:
	if is_mapped(state):
		state_map.erase(state)
	else:
		push_warning("state "+str(state)+" not found.")
