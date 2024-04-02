extends TestPlayerMovementState

@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fallwall_state : State

# var belong : Status = Status.new(["belong"]) # appropriate declaration
# var action : Status = Status.new(["belong"]) # appropriate declaration
# var floor : Status = Status.new(["belong"]) # appropriate declaration
# var wall : Status = Status.new(["belong"]) # appropriate declaration

func _ready():
	animation_variations = [["fall"], ["fall_loop"]]

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.floor.ing:
		if abs(movement.velocity.x) > 50.0:
			land_state.set_variation(1)
		else:
			land_state.set_variation(0)
		return land_state
	if logic.wall.ing:
		return fallwall_state
	return self

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	side_move_physics_process(delta)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	return self
