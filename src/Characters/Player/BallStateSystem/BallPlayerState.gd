extends State
class_name BallPlayerState

@export var player : NewPlayer
@export var logic : PlayerStatusLogic
@export var ball_handler : BallHandler

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	return self
func physics_process(delta) -> State:
	return self

func branch() -> State:
	# do some logic
	return self

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	print("                "+self.name)
	return next_state

func exit():
	pass

func release_ball():
	if ball_handler.throw_ball(player.global_position, Vector2.ZERO):
		print("                release ball")
