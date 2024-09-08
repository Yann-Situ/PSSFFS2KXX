extends PlayerMovementState

@export var walljump_velocity : Vector2 = Vector2(250, -350.0) ## pix/s, supposed to be toward the right
@export var mountwalljump_velocity : Vector2 = Vector2(250, -350.0) ## pix/s, when mounting and walljump, gets a bit higher (new mechanic)
@export var mountwalljump_thresh : float = -30.0 ## pix/s, thresh of mountwalljump: if velocity.y is below this value, then perform a mountwalljump
## ratio applied to the vertical velocity after releasing up button
@export var jump_speed_up_cancelled_ratio : float = 0.5 ## when up is released, multiply the up velocity by this amount
@export var jump_speed_down_cancelled_ratio : float = 0.1 ## when down is just pressed, multiply the up velocity by this amount
@export var no_jump_delay : float = 0.2 ## s
@export var no_side_delay : float = 0.2 ## s

@export_group("States")
@export var belong_state : State
@export var action_state : State
@export var land_state : State
@export var fallwall_state : State
@export var fall_state : State

var first_frame = false # true if we just enter the jump state
var up_cancelled = false # true if this jump was cancelled by releasing up_button
var cancelled = false # true if this jump was cancelled by pressing down_button or releasing up_button

func _ready():
	animation_variations = [["walljump1"]]

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.action.can:
		return action_state

	if !first_frame:
		if logic.floor.ing:
			return land_state
		if logic.wall.ing:
			return fallwall_state
		if movement.velocity.y > 0.0:
			return fall_state
	return self

func enter(previous_state : State = null) -> State:
	first_frame = true
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()

	logic.walljump.ing = true # actually not used (?)
	logic.jump.ing = true # actually not used (?)
	up_cancelled = false
	cancelled = false
	logic.no_jump_timer.start(no_jump_delay)
	logic.no_side_timer.start(no_side_delay)
	logic.jump_press_timer.stop()
	if movement.velocity.y < mountwalljump_thresh:
		print(self.name+" mount*")
		movement.velocity.y = mountwalljump_velocity.y
		movement.velocity.x = -logic.direction_wall * mountwalljump_velocity.x
		player.effect_handler.cloud_start(8, 8)
	else:
		print(self.name)
		movement.velocity.y = walljump_velocity.y
		movement.velocity.x = -logic.direction_wall * walljump_velocity.x
	
	if !logic.up.pressed:
		movement.velocity.y *= jump_speed_up_cancelled_ratio
		print("  | enter cancelled jump")
		up_cancelled = true

	# effects
	player.effect_handler.dust_start()
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
	if first_frame :
		first_frame = false # TEMPORARY Hack to avoid Stand->Jump->Stand transitions
	return self

	## Called just before entering the next State. Should not contain await or time
	## stopping functions
func exit():
	super()
	logic.jump.ing = false
	logic.walljump.ing = false
