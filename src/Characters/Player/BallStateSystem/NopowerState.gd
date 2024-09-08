extends BallPlayerState

@export_group("States")
@export var power_state : State

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	## TODO update ball.sprite position with has_ball_position or use a remote2D to handle this.
	if ball_handler.has_ball():
		pass
	return self

func physics_process(delta) -> State:
	if logic.release.can and logic.key_release.just_pressed:
		release_ball()
	#print("nopower " + str(ball_handler.has_selected_ball()) + " " + str(ball_handler.has_ball()) + " " + str(logic.key_release.pressed))
	var next_state = branch()
	if next_state != self:
		return next_state
	return self

func branch() -> State:
	if logic.power.can and logic.key_power.pressed and ball_handler.has_selected_ball():
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
