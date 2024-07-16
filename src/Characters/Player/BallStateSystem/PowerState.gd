extends BallPlayerState

@export_group("States")
@export var holdball_state : State
@export var noball_state : State

var ball_at_enter : Ball = null

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	ball.power_p(player, delta) ## TODO implement physics power and process power
	return self
func physics_process(delta) -> State:
	return self

func branch() -> State:
	if !logic.power.can or !logic.power.pressed or\
			!ball_handler.has_selected_ball() or\
			ball_at_enter != ball_handler.selected_ball:
		if ball_handler.has_ball():
			return holdball_state
		else:
			return noball_state
	return self

func enter(previous_state : State = null) -> State:
	ball_at_enter == ball_handler.selected_ball # might be null
	var next_state = branch()
	if next_state != self:
		return next_state
	print("                "+self.name)

	assert(ball_at_enter != null)
	ball.power_jp(player, 0.0)
	return next_state

func exit():
	ball.power_jr(player, 0.0)
