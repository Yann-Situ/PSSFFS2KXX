extends PlayerMovementState

@export var speed_ratio : float = 0.3 ## ratio applied to speed_max, instant_speed and instant_speed_thresh.
@export var accel_ratio : float = 0.3 ## ratio applied to accel
#need to handle hit/collision box resizing + crouch parameters + jump

@export var belong_state : State
@export var action_state : State
@export var fall_state : State
@export var stand_state : State

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.action.can:
		return action_state
	if !logic.floor.ing:
		return fall_state

	if logic.stand.can and !logic.down.pressed:
		return stand_state
	return self

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	logic.crouch.ing = true
	# change hitbox
	print("CROUCH")
	return next_state

func side_crouch_physics_process(delta):
	if logic.direction_pressed.x == 0.0:
		return
	if -movement.side_instant_speed_return_thresh*speed_ratio < movement.velocity.x*logic.direction_pressed.x \
		and movement.velocity.x*logic.direction_pressed.x < movement.side_instant_speed*speed_ratio :
		movement.velocity.x = logic.direction_pressed.x*movement.side_instant_speed*speed_ratio
	if (movement.velocity.x*logic.direction_pressed.x >= movement.side_speed_max*speed_ratio) :
		pass # in the same logic.direction_pressed.x as velocity and faster than max
	else :
		movement.velocity.x += logic.direction_pressed.x*movement.side_accel*accel_ratio*delta
		if (movement.velocity.x*logic.direction_pressed.x > movement.side_speed_max*speed_ratio) :
			movement.velocity.x = logic.direction_pressed.x*movement.side_speed_max*speed_ratio

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# handle run and walls ?
	side_crouch_physics_process(delta)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	return self


## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	logic.crouch.ing = false
