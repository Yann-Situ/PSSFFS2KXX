extends PlayerMovementState

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

	if logic.jump.can and logic.jump_press_timing:
		#logic.floor.ing = false # TEMPORARY solution to avoid infinite recursion
		return jump_state
	if !logic.floor.ing:
		return fall_state

	if logic.side.ing and logic.crouch.can and logic.down.pressed and \
			abs(movement.velocity.x) > slide_speed_thresh:
		return slide_state

	if logic.crouch.ing or (logic.crouch.can and logic.down.pressed):
		return crouch_state
	return self

func animation_process() -> void:
	set_variation(0) # ["idle"]
	if logic.direction_sprite_changed:
		set_variation(3) # ["turn"]
	else if logic.side.ing :
		if (logic.direction_pressed.x == 0):
			set_variation(2) # ["standstop"]
		else :
			set_variation(1) # ["walk"]
	play_animation(true) # with priority
