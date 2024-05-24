extends PlayerMovementState

@export var belong_handler : BelongHandler

@export_group("States")
@export var hang_state : State # rope, zip, basket
@export var grind_state : State
@export var no_control_state : State

@export var fall_state : State

func branch() -> State:
	if !belong_handler.is_belonging():
		printerr("branch belong state but not belong_handler.is_belonging()")
		return fall_state

	# switch / match, depending on the holders
	#	if
	return hang_state

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	logic.holder_change = false
	print(self.name)
	return next_state
