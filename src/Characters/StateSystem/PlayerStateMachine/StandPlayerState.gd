extends PlayerMovementState

@export var belong_state : State
@export var action_state : State
@export var jump_state : State
@export var fall_state : State
@export var slide_state : State
@export var standstop_state : State
@export var crouch_state : State
@export var turn_state : State

# # We just export the logic
# var belong : Status = Status.new("belong") # appropriate declaration
# var action : Status = Status.new("action") # appropriate declaration
# var jump : Status = Status.new("jump") # appropriate declaration
# var floor : Status = Status.new("floor") # appropriate declaration
# var run : Status = Status.new("run") # appropriate declaration
# var crouch : Status = Status.new("crouch") # appropriate declaration
#
# var up : Trigger = Trigger.new("up") # appropriate declaration
# var down : Trigger = Trigger.new("down") # appropriate declaration
# var left : Trigger = Trigger.new("left") # appropriate declaration
# var right : Trigger = Trigger.new("right") # appropriate declaration

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.jump.can and logic.up.just_pressed: # TODO handle tolerance
		#logic.floor.ing = false # TEMPORARY solution to avoid infinite recursion
		return jump_state
	if !logic.floor.ing:
		return fall_state

	if logic.run.ing :
		if (logic.crouch.can and logic.down.pressed):
			return slide_state
		if (logic.direction_pressed.x == 0):
			return standstop_state
	if logic.crouch.ing or (logic.crouch.can and logic.down.pressed):
		return crouch_state
	if logic.direction_sprite*logic.direction_pressed.x < 0:
		return turn_state
	return self

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# handle run and walls ?
	side_move_physics_process(delta)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	return self
