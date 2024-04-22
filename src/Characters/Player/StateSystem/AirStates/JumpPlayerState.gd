extends PlayerMovementState

@export var jump_speed : float = -425.0 # pix/s
## ratio applied to the vertical velocity after releasing up button
@export var jump_speed_up_cancelled_ratio : float = 0.5
@export var jump_speed_down_cancelled_ratio : float = 0.1

@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fallwall_state : State
@export var fall_state : State

# var jump : Status = Status.new(["jump"]) # appropriate declaration
# var belong : Status = Status.new(["jump"]) # appropriate declaration
# var action : Status = Status.new(["jump"]) # appropriate declaration
# var floor : Status = Status.new(["jump"]) # appropriate declaration
# var wall : Status = Status.new(["jump"]) # appropriate declaration
#
# var up : Trigger = Trigger.new(["jump"]) # appropriate declaration
var first_frame = false # true if we just enter the jump state
var up_cancelled = false # true if this jump was cancelled by releasing up_button
var cancelled = false # true if this jump was cancelled by pressing down_button or releasing up_button

func _ready():
	animation_variations = [["jump"], ["turn_jump"], ["frontflip"]]

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.action.can:
		return action_state

	if !first_frame and logic.floor.ing:
		return land_state
	if logic.wall.ing:
		return fallwall_state
	if !first_frame and movement.velocity.y > 0.0:
		return fall_state
	return self

func enter(previous_state : State = null) -> State:
	first_frame = true
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()
	logic.jump.ing = true # actually not used (?)
	up_cancelled = false
	cancelled = false
	movement.velocity.y += jump_speed
	if !logic.up.pressed:
		movement.velocity.y *= jump_speed_up_cancelled_ratio
		print("  | enter cancelled jump")
		up_cancelled = true

	# TODO
	#player.PlayerEffects.dust_start()
	#player.PlayerEffects.jump_start()

	print(self.name)
	return next_state

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	if !up_cancelled and logic.up.just_released:
		movement.velocity.y *= jump_speed_up_cancelled_ratio
		print("  | up cancelled jump")
		up_cancelled = true
	if !cancelled and logic.down.just_pressed:
		movement.velocity.y *= jump_speed_down_cancelled_ratio
		print("  | down cancelled jump")
		up_cancelled = true
		cancelled = true

	side_move_physics_process(delta)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	if first_frame and !logic.floor.ing :
		first_frame = false # TEMPORARY Hack to avoid Stand->Jump->Stand transitions
	return self

	## Called just before entering the next State. Should not contain await or time
	## stopping functions
	func exit():
		super()
		logic.jump.ing = false
