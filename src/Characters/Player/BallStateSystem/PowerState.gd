extends BallPlayerState

@export_group("States")
@export var nopower_state : State

var ball_at_enter : Ball = null

## WARNING branch() is called once per process and physics_process, maybe just
# put it in physics_process ? It may induce undefined behavior though...
# I decided to put it in both for stability and predictability.

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	if ball_handler.has_ball_and_is_selected():
		ball_at_enter.power_p_hold(player, delta)
	else:
		ball_at_enter.power_p(player, delta)
	return self

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic process call.
func physics_process(delta) -> State:
	if logic.release.can and logic.key_release.just_pressed:
		release_ball()

	var next_state = branch()
	if next_state != self:
		return next_state

	if ball_handler.has_ball_and_is_selected():
		ball_at_enter.power_p_physics_hold(player, delta)
	else:
		ball_at_enter.power_p_physics(player, delta)
	return self

func branch() -> State:
	if !logic.power.can or !logic.key_power.pressed or\
			!ball_handler.has_selected_ball() or\
			ball_at_enter != ball_handler.selected_ball:
		return nopower_state
	return self

func enter(previous_state : State = null) -> State:
	ball_at_enter = ball_handler.selected_ball # might be null
	var next_state = branch()
	if next_state != self:
		return next_state
	print("                "+self.name)

	assert(ball_at_enter != null)
	#print(ball_at_enter.name + "jp")
	if ball_handler.has_ball_and_is_selected():
		ball_at_enter.power_jp_hold(player, 0.0)
	else:
		ball_at_enter.power_jp(player, 0.0)

	return next_state

func exit():
	if ball_at_enter == null:
		push_error("ball_at_enter is null at exit()")
		return
	#print(ball_at_enter.name + "jr")
	if ball_handler.has_ball_and_is_selected():
		ball_at_enter.power_jr_hold(player, 0.0)
	else:
		ball_at_enter.power_jr(player, 0.0)
