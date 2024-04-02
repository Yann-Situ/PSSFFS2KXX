extends TestPlayerMovementState

@export var slide_speed_thresh : float = 200.0

@export var belong_state : State
@export var action_state : State
@export var jump_state : State
@export var fall_state : State
@export var slide_state : State
@export var standstop_state : State
@export var crouch_state : State
@export var turn_state : State

# # We just export the logic
# var belong : Status = Status.new(["belong"]) # appropriate declaration
# var action : Status = Status.new(["belong"]) # appropriate declaration
# var jump : Status = Status.new(["belong"]) # appropriate declaration
# var floor : Status = Status.new(["belong"]) # appropriate declaration
# var run : Status = Status.new(["belong"]) # appropriate declaration
# var crouch : Status = Status.new(["belong"]) # appropriate declaration
#
# var up : Trigger = Trigger.new(["belong"]) # appropriate declaration
# var down : Trigger = Trigger.new(["belong"]) # appropriate declaration
# var left : Trigger = Trigger.new(["belong"]) # appropriate declaration
# var right : Trigger = Trigger.new(["belong"]) # appropriate declaration

func _ready():
	animation_variations = [["idle"], ["walk"], ["standstop"], ["turn"]]

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

	set_variation(0) # ["idle"]
	if logic.run.ing :
		if (logic.crouch.can and logic.down.pressed and \
			abs(movement.velocity.x) > slide_speed_thresh):
			return slide_state
		if (logic.direction_pressed.x == 0):
			#return standstop_state
			set_variation(2) # ["turn"]
			play_animation(true)
			return self
		set_variation(1) # ["standstop"]
		play_animation(true)

	if logic.crouch.ing or (logic.crouch.can and logic.down.pressed):
		return crouch_state
	if logic.direction_sprite_changed:
		#return turn_state
		set_variation(3) # ["walk"]
	play_animation(true)
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
