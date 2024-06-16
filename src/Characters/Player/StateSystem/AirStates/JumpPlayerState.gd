extends PlayerMovementState

@export var jump_speed : float = -425.0 # pix/s
## ratio applied to the vertical velocity after releasing up button
@export var jump_speed_up_cancelled_ratio : float = 0.5
@export var jump_speed_down_cancelled_ratio : float = 0.1
@export var no_jump_delay : float = 0.2 ## s
@export var min_jump_duration : float = 0.1 ## s # duration between the beginning of the jump to the first frame where land/fallwall/fall is possible

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fallwall_state : State
@export var fall_state : State

var min_duration_timer : Timer # time the duration between the beginning of the
# jump to the first frame where land/fallwall/fall is possible
var up_cancelled = false # true if this jump was cancelled by releasing up_button
var cancelled = false # true if this jump was cancelled by pressing down_button or releasing up_button

func _ready():
	animation_variations = [["jump1"], ["turn_jump"], ["frontflip"]]
	min_duration_timer = Timer.new()
	min_duration_timer.autostart = false
	min_duration_timer.one_shot = true
	min_duration_timer.wait_time = min_jump_duration
	add_child(min_duration_timer)

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if min_duration_timer.is_stopped():
		if logic.floor.ing:
			return land_state
		if logic.wall.ing:
			return fallwall_state
		if movement.velocity.y > 0.0:
			return fall_state
	return self

func enter(previous_state : State = null) -> State:
	min_duration_timer.start()
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()

	logic.jump.ing = true # actually not used (?)
	up_cancelled = false
	cancelled = false
	logic.no_jump_timer.start(no_jump_delay)
	logic.jump_press_timer.stop()
	movement.velocity.y = jump_speed
	if !logic.up.pressed:
		# TODO special animation for a mini jump?
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

	if !up_cancelled and !logic.up.pressed:
		movement.velocity.y *= jump_speed_up_cancelled_ratio
		print("  | up cancelled jump")
		up_cancelled = true
	if !cancelled and logic.down.pressed:
		movement.velocity.y *= jump_speed_down_cancelled_ratio
		print("  | down cancelled jump")
		up_cancelled = true
		cancelled = true

	side_move_physics_process(delta)

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	return self

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.jump.ing = false
	min_duration_timer.stop()
