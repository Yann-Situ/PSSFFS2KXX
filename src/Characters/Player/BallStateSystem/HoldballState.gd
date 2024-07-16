extends BallPlayerState

@export_group("States")
@export var power_state : State
@export var noball_state : State

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	## TODO update ball.sprite position with has_ball_position or use a remote2D to handle this.
	return self
func physics_process(delta) -> State:
	return self

func branch() -> State:
	if !ball_handler.has_ball():
		return noball_state
	if logic.power.can and logic.power.pressed and ball_handler.has_selected_ball():
		return power_state
	return self

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	print("                "+self.name)
	## TODO handle ballwall and co
	return next_state

func exit():
	pass
