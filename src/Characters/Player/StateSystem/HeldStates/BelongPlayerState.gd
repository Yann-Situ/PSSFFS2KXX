extends PlayerMovementState

@export var belong_handler : BelongHandler

@export_group("States")
@export var hang_state : State # rope, zip, basket
@export var grind_state : State
@export var follow_state : State

@export var fall_state : State

func branch() -> State:
	if !belong_handler.is_belonging():
		printerr("branch belong state but not belong_handler.is_belonging()")
		return fall_state

	# switch / match, depending on the holders
	var holder : CharacterHolder = belong_handler.current_holder
	match holder.holder_type:#{NO_TYPE, GRIND, HANG, FOLLOW, ROLL}
		holder.HOLDER_TYPE.GRIND:
			return grind_state
		holder.HOLDER_TYPE.HANG:
			return hang_state
		holder.HOLDER_TYPE.FOLLOW:
			return follow_state
		_:
			belong_handler.get_out()
			return fall_state

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	logic.holder_change = false
	print(self.name)
	return next_state

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.belong.ing = belong_handler.is_belonging()
