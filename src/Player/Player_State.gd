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
export (float) var dunk_countdown = 100*frame_time_ms #s
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
var select_jp = false
var power_p = false
var power_jp = false
var power_jr = false

# Bool for action permission
var can_jump = false
var can_walljump = false
var can_go = false
var can_crouch = false
var can_aim = false
var can_shoot = false
var can_dunkjump = false
var can_dunk = false
var can_stand = false

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
var velocity = Vector2()

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
export var is_jumping = false # handle also by Player.gd
export var is_walljumping = false # handle also by Player.gd
export var is_landing = false # handle also by animations (for stop)
export var is_landing_roll = false # handle also by animations (for stop)
export var is_dunkjumping = false # handle also by Player.gd
export var is_dunking = false # handle also by Player.gd
export var is_halfturning = false # handle also by Player.gd
export var is_crouching = false # handle also by Player.gd
export var is_aiming = false # handle by Player.gd
export var is_shooting = false # handle by Player.gd (for start) and animations (for stop)

# Bool var
export var has_ball = false
var active_ball = null#pointer to a ball
var selected_ball = null#pointer to the selected ball
var selected_basket = null#pointer to the basket to dunk

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

	right_p = Input.is_action_pressed('ui_right')
	left_p = Input.is_action_pressed('ui_left')
	jump_jp = Input.is_action_just_pressed('ui_up')
	jump_p = Input.is_action_pressed('ui_up')
	jump_jr = Input.is_action_just_released('ui_up')
	crouch_p = Input.is_action_pressed('ui_down')
	aim_jp = Input.is_action_just_pressed("ui_select")
	shoot_jr = Input.is_action_just_released("ui_select")
	dunk_p = Input.is_action_pressed("ui_accept")
	dunk_jr =  Input.is_action_just_released("ui_accept")
	select_jp = Input.is_action_just_pressed("ui_select_alter")
	power_p =  Input.is_action_pressed("ui_power")
	power_jp =  Input.is_action_just_pressed("ui_power")
	power_jr =  Input.is_action_just_released("ui_power")
	
	if jump_jp:
		$ToleranceJumpPressTimer.start(tolerance_jump_press)
	
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

	can_jump = not $ToleranceJumpFloorTimer.is_stopped() and \
		$CanJumpTimer.is_stopped()
	can_walljump = not $ToleranceWallJumpTimer.is_stopped() and \
		$CanJumpTimer.is_stopped()
	can_go = $CanGoTimer.is_stopped() and not is_dunkjumping
	can_crouch = is_onfloor
	can_aim = $CanShootTimer.is_stopped() and has_ball and active_ball != null
	can_shoot = is_aiming and has_ball and active_ball != null
	can_dunkjump = $CanDunkJumpTimer.is_stopped() and \
		Player.SpecialActionHandler.can_dunkjump()
	can_dunk = $CanDunkTimer.is_stopped() and \
		(is_dunkjumping or (not is_onfloor and crouch_p)) and \
		Player.SpecialActionHandler.can_dunk()
	can_stand = Player.SpecialActionHandler.can_stand()
	
	var dir_sprite = 1;
	if self.get_parent().flip_h :
		dir_sprite = -1;
	is_jumping = is_jumping and not is_onfloor and is_mounting
	is_walljumping = is_walljumping and not is_onfloor and is_mounting
	is_dunkjumping = is_dunkjumping and not is_onfloor and dunk_p
	is_dunking = is_dunking # handle by player actions (start) and animation (stop but not yet implemented)
	is_halfturning = (is_halfturning or dir_sprite*direction_p == -1) and is_onfloor and direction_p != 0 and not is_shooting # handle by player actions
	is_landing = is_onfloor and not is_onwall and (is_landing or (last_frame_onair and last_onair_velocity_y > Player.landing_velocity_thresh)) and not is_halfturning# stop also handled by animation
	is_landing_roll = is_landing and (abs(velocity.x) > 100.0)
	is_crouching = (is_onfloor and is_crouching) or not can_stand# handle by player actions (start)
	is_aiming = is_aiming and has_ball and active_ball != null and not is_dunkjumping
	#is_shooting handle by shoot animation+Player.gd



