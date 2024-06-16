extends PlayerMovementState

@export var ambient_modifier : AmbientDataScaler ## ambient modifier, to slow the acceleration during crouch
#need to handle hit/collision box resizing + crouch parameters + jump

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fall_state : State
@export var walljump_state : State

# var belong : Status = Status.new(["belong"]) # appropriate declaration
# var action : Status = Status.new(["belong"]) # appropriate declaration
# var floor : Status = Status.new(["belong"]) # appropriate declaration
# var wall : Status = Status.new(["belong"]) # appropriate declaration

func _ready():
	animation_variations = [["air_wall"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.walljump.can and !logic.jump_press_timer.is_stopped():
		#logic.floor.ing = false # TEMPORARY solution to avoid infinite recursion
		return walljump_state
	if logic.floor.ing:
		return land_state
	if !logic.wall.ing:
		return fall_state
	return self

# func animation_process() -> void:
# 	pass

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	var m : MovementData = movement.duplicate_with_ambient_scaler(ambient_modifier)
	side_move_physics_process(delta, m)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta, m)

	# TODO : weird handling of velocity due to being inside movementdata:
	movement.velocity = m.velocity
	return self
