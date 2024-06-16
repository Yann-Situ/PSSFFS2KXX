extends PlayerMovementState

@export_group("States")
@export var exit_state : State

func _ready():
	animation_variations = [] # [["animation_1", "animation_2"]]

func branch() -> State:
	# if logic.belong_ing:
	# 	return belong_state
	# if logic.action.can:
	# 	return action_state
	return self
