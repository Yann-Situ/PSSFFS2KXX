extends Node

onready var Player = get_parent()

var frame_time_ms = 1.0/60.0 #s
var time = 0.0#s

# Countdowns and delays between actions
export (float) var tolerance_jump_floor = 9*frame_time_ms #s
export (float) var tolerance_jump_press = 9*frame_time_ms #s
export (float) var tolerance_wall_jump = 9*frame_time_ms #s
export (float) var tolerance_land_lag = 3*frame_time_ms #s
export (float) var walljump_move_countdown = 22*frame_time_ms #s
export (float) var jump_countdown = 10*frame_time_ms #s
export (float) var dunkjump_countdown = 0.4#s
export (float) var dunk_countdown = 1.5 #s
export (float) var shoot_countdown = 30*frame_time_ms #s

# Bool for inputs ('p' is for 'pressed', 'jp' 'just_pressed', 'jr' 'just_released')
var right_p = false
var left_p = false
var jump_jp = false
var jump_p = false
var jump_jr = false
var crouch_p = false
var aim_jp = false
var shoot_jr = false
var dunk_p = false
var dunk_jr = false
var dunk_jp = false
var select_jp = false
var power_p = false
var power_jp = false
var power_jr = false
var release_jp = false

# Bool for action permission
var can_jump = false
var can_walljump = false
var can_go = false
var can_crouch = false
var can_aim = false
var can_shoot = false
var can_dunkjump = false
var can_dunkdash = false
var can_dunk = false
var can_stand = false
var can_grind = false
var can_hang = false

# Bool for physical states
var is_onfloor = false # from values of Player.gd
var is_onwall = false # from values of Player.gd
var is_moving_fast = false # from values of Player.gd
var is_falling = false
var is_mounting = false
var is_moving = false
var is_idle = false
#var is_slowing = false
#var is_speeding = false

# Utilities
export var move_direction = 0
var direction_p = 0
var aim_direction = 0
export var velocity = Vector2()

# Delays and states memory # handle by Player.gd
#var last_onfloor = 0
var last_frame_onair = false
#var last_onwall = 0
#var last_jump = 0
#var last_walljump = 0
var last_wall_normal_direction = 0 # handle by Player.gd
var last_onair_velocity_y = 0
#var last_shoot = 0
var last_aim_jp = 0 # still used for shoot vector

# Bool for actions
export var is_jumping = false
export var is_walljumping = false
export var is_landing = false
export var is_landing_roll = false
export var is_dunkjumping = false
export var is_dunkprejumping = false
export var is_dunkdashing = false
export var is_dunking = false
export var is_halfturning = false
export var is_crouching = false
export var is_aiming = false
export var is_shooting = false

export var is_grinding = false
export var is_hanging = false

var is_non_cancelable = false
var is_dunkjumphalfturning = false
enum ActionType { NONE, SHOOT, DUNK, DUNKDASH, DUNKJUMP }
var action_type = ActionType.NONE

# Bool var
export var has_ball = false
var active_ball = null#pointer to a ball
var released_ball = null # useful because when the ball is released (or thrown)
# it is immediatly detected by area_body_enter...
var selected_ball = null#pointer to the selected ball
var dunkjump_basket = null#pointer to the basket to dunkjump
var dunk_basket = null

func _ready():
	reset_state()

func _input(event):

	right_p = Input.is_action_pressed('ui_right')
	left_p = Input.is_action_pressed('ui_left')
	jump_jp = Input.is_action_just_pressed('ui_up')
	jump_p = Input.is_action_pressed('ui_up')
	jump_jr = Input.is_action_just_released('ui_up')
	crouch_p = Input.is_action_pressed('ui_down')
	aim_jp = Input.is_action_just_pressed("ui_select")
	shoot_jr = Input.is_action_just_released("ui_select")
	dunk_p = Input.is_action_pressed("ui_accept")
	dunk_jp = Input.is_action_just_pressed("ui_accept")
	dunk_jr =  Input.is_action_just_released("ui_accept")
	select_jp = Input.is_action_just_pressed("ui_select_alter")
	power_p =  Input.is_action_pressed("ui_power")
	power_jp =  Input.is_action_just_pressed("ui_power")
	power_jr =  Input.is_action_just_released("ui_power")
	release_jp =  Input.is_action_just_pressed("ui_release")

	if jump_jp:
		$ToleranceJumpPressTimer.start(tolerance_jump_press)
	if dunk_jp:
		$ToleranceDunkJumpPressTimer.start(tolerance_jump_press)

func set_action(v): # for non_cancelable actions
	action_type = v
	match action_type:
		ActionType.NONE:
			is_shooting = false
			is_dunkdashing = false
			is_dunking = false
			is_dunkjumping = false
			is_dunkprejumping = false
		ActionType.SHOOT:
			is_dunkdashing = false
			is_dunking = false
			is_dunkjumping = false
			is_dunkprejumping = false
		ActionType.DUNK:
			is_dunkdashing = false
			is_shooting = false
			is_dunkjumping = false
			is_dunkprejumping = false
		ActionType.DUNKDASH:
			is_dunking = false
			is_shooting = false
			is_dunkjumping = false
			is_dunkprejumping = false
		ActionType.DUNKJUMP:
			is_dunkdashing = false
			is_shooting = false
			is_dunking = false
	is_non_cancelable = action_type != ActionType.NONE

func update_action(): # for non_cancelable actions with the following priority
	if is_shooting:
		set_action(ActionType.SHOOT)
	elif is_dunking:
		set_action(ActionType.DUNK)
	elif is_dunkjumping:
		set_action(ActionType.DUNKJUMP)
	elif is_dunkdashing:
		set_action(ActionType.DUNKDASH)
	else :
		set_action(ActionType.NONE)

func update_vars(delta):
	#
	# Delays and states memory should be updated after calling update_vars()
	# in Player.gd
	#
	time += delta # still used in the current shoot vector implementation... to change

	last_frame_onair = not is_onfloor

	Player.SpecialActionHandler.update_space_state()
	Player.SpecialActionHandler.update_basket()

	is_onfloor = Player.SpecialActionHandler.is_on_floor()
	is_onwall = Player.SpecialActionHandler.is_on_wall()
	is_moving_fast = (abs(velocity.x) > Player.run_speed_thresh)
	is_falling =  (not is_onfloor) and velocity.y > 0
	is_mounting = (not is_onfloor) and velocity.y < 0
	is_moving = (abs(velocity.x) > 5.0) or (abs(velocity.y) > 5.0)
	is_idle = (abs(velocity.x) <= 5.0)

	if (velocity.x == 0):
		move_direction = 0
	elif (velocity.x < 0):
		move_direction = -1
	else :
		move_direction = 1

	#var direction_p_previous_frame = direction_p
	direction_p = 0
	if right_p :
		direction_p += 1
	if left_p :
		direction_p -= 1

	var dir_sprite = 1;
	if self.get_parent().flip_h :
		dir_sprite = -1;

	# non-cancelables :
	#is_shooting = is_shooting
	#is_dunking = is_dunking
	is_dunkdashing = is_dunkdashing and not is_onfloor and dunk_p
	is_dunkprejumping = is_dunkprejumping and !(is_dunking or is_dunkdashing)
	is_dunkjumping = (is_dunkjumping  and \
		!(is_onfloor or (is_onwall and is_falling) or is_dunking or \
			is_dunkdashing or is_hanging or is_grinding)) or \
		is_dunkprejumping
	update_action()

	# possibilities can_*
	can_jump = not $ToleranceJumpFloorTimer.is_stopped() and \
		$CanJumpTimer.is_stopped()
	can_walljump = not $ToleranceWallJumpTimer.is_stopped() and \
		$CanJumpTimer.is_stopped()
	can_go = $CanGoTimer.is_stopped() and not (is_dunkjumping and dunk_p) and \
		not is_dunkdashing and not is_dunking
	can_crouch = is_onfloor
	can_aim = $CanShootTimer.is_stopped() and has_ball and active_ball != null and not is_dunking
	can_shoot = is_aiming and has_ball and active_ball != null
	can_dunkdash = can_jump and Player.SpecialActionHandler.can_dunkjump() and not is_non_cancelable
	can_dunkjump = can_dunkdash and $CanDunkjumpTimer.is_stopped()
	can_dunk = $CanDunkTimer.is_stopped() and \
		((not is_onfloor and dunk_p)) and \
		Player.SpecialActionHandler.can_dunk() and not is_shooting and not is_dunkprejumping
	can_stand = Player.SpecialActionHandler.can_stand()
	can_grind = !is_hanging and !is_dunking
	can_hang = true

	# cancelables :
	is_jumping = is_jumping and not is_onfloor and is_mounting
	is_walljumping = is_walljumping and is_jumping
	is_crouching = (is_onfloor and is_crouching) or not can_stand# handle by player actions (start)

	is_hanging = is_hanging and !crouch_p
	is_grinding = is_grinding and !is_hanging and !crouch_p

	is_landing = is_onfloor and not is_onwall and (is_landing or \
		(last_frame_onair and last_onair_velocity_y > Player.landing_velocity_thresh)) and \
		not is_non_cancelable# stop also handled by animation
	is_landing_roll = is_landing and (abs(velocity.x) > 100.0)
	is_halfturning = (is_halfturning or dir_sprite*direction_p == -1) and \
		is_onfloor and !(is_idle or direction_p == 0 or is_crouching or is_landing or \
			is_onwall or is_non_cancelable) # handle by player actions
	is_aiming = is_aiming and has_ball and active_ball != null and not is_non_cancelable

###############################################################################
func disable_input():
	set_process_input(false)
	right_p = false
	left_p = false
	jump_jp = false
	jump_p = false
	jump_jr = false
	crouch_p = false
	aim_jp = false
	shoot_jr = false
	dunk_p = false
	dunk_jr = false
	dunk_jp = false
	select_jp = false
	power_p = false
	power_jp = false
	power_jr = false
	release_jp = false

func enable_input():
	set_process_input(true)

func reset_state():
	can_jump = false
	can_walljump = false
	can_go = false
	can_crouch = false
	can_aim = false
	can_shoot = false
	can_dunkjump = false
	can_dunkdash = false
	can_dunk = false
	can_stand = false
	can_grind = false
	can_hang = false

	is_onfloor = false
	is_onwall = false
	is_moving_fast = false
	is_falling = false
	is_mounting = false
	is_moving = false
	is_idle = false

	move_direction = 0
	direction_p = 0
	aim_direction = 0
	velocity = Vector2.ZERO

	last_frame_onair = false
	last_wall_normal_direction = 0
	last_onair_velocity_y = 0
	last_aim_jp = 0

	is_jumping = false
	is_walljumping = false
	is_landing = false
	is_landing_roll = false
	is_dunkjumping = false
	is_dunkdashing = false
	is_dunking = false
	is_halfturning = false
	is_crouching = false
	is_aiming = false
	is_shooting = false
	is_grinding = false
	is_hanging = false

	is_non_cancelable = false
	is_dunkjumphalfturning = false

	has_ball = false
	active_ball = null
	released_ball = null
	selected_ball = null
	dunkjump_basket = null
	dunk_basket = null
