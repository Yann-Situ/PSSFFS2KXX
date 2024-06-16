extends PlayerMovementState

@export var slide_speed_thresh : float = 200.0

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var jump_state : State
@export var fall_state : State
@export var slide_state : State
@export var crouch_state : State

func _ready():
	animation_variations = [["idle"], ["walk"], ["grind-30"], ["halfturn"]] # TODO animation_variations[1] should be ["standstop"]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if logic.jump.can and !logic.jump_press_timer.is_stopped():
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
	if logic.direction_sprite_change.ing:
		set_variation(3) # ["turn"]
	elif logic.side.ing :
		if (logic.direction_pressed.x == 0):
			set_variation(2) # ["standstop"]
		else :
			set_variation(1) # ["walk"]
	play_animation(true) # with priority
