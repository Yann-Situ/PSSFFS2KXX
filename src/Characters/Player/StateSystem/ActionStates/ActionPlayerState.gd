extends PlayerState

@export_group("States")
@export var dunk_state : State
@export var dunkdash_state : State
@export var dunkjump_state : State
@export var shoot_state : State
@export var fall_state : State

func branch() -> State:
	# ordered in priority
#	if logic.dunk.can and logic.accept.pressed:
#		return dunk_state
#	if logic.dunkjump.can and logic.accept.just_pressed:
#		return dunkjump_state
	if logic.dunkdash.can and logic.accept.just_pressed:
		return dunkdash_state
#	if logic.shoot.can and logic.key_release.pressed:
#		return shoot_state
	printerr("branch action state but no action possible")
	return fall_state

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	print(self.name)
	return next_state
