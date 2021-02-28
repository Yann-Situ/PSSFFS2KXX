extends Node

var frame_time_ms = 1000/60 #ms
export var time = 0 #ms

# Countdowns and delays between actions
export (float) var jump_lag_tolerance = 8*frame_time_ms #ms
export (float) var walljump_move_countdown = 22*frame_time_ms #ms
export (float) var jump_countdown = 10*frame_time_ms #ms
export (float) var shoot_countdown = 30*frame_time_ms #ms
export (float) var land_lag_tolerance = 3*frame_time_ms #ms

# Bool for inputs ('p' is for 'pressed', 'jp' 'just_pressed', 'jr' 'just_released')
var right_p = false
var left_p = false
var jump_jp = false
var jump_jr = false
var crouch_p = false
var aim_jp = false
var shoot_jr = false
var dunk_p = false
var select_jp = false

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

# Bool for action permission
var can_jump = false
var can_walljump = false
var can_go = false
var can_crouch = false
var can_aim = false
var can_shoot = false
var can_dunk = false

# Utilities
export var move_direction = 0
var direction_p = 0
var aim_direction = 0
var velocity = Vector2()

# Delays and states memory # handle by Player.gd
var last_onfloor = 0
var last_onair = 0
var last_onwall = 0
var last_jump = 0
var last_walljump = 0
var last_wall_normal_direction = 0 # handle by Player.gd
var last_shoot = 0
var last_aim_jp = 0

# Bool for actions
export var is_jumping = false # handle also by Player.gd
export var is_walljumping = false # handle also by Player.gd
export var is_landing = false # handle also by animations (for stop)
export var is_dunking = false # handle also by Player.gd
export var is_halfturning = false # handle also by Player.gd
export var is_crouching = false # handle also by Player.gd
export var is_aiming = false # handle by Player.gd
export var is_shooting = false # handle by Player.gd (for start) and animations (for stop)

# Bool var
export var has_ball = false
var active_ball = null#pointer to a ball
var selected_ball = null#pointer to the selected ball

func update_vars(delta_ms, onfloor, onwall, movingfast):
	#
	# Delays and states memory should be updated after calling update_vars()
	# in Player.gd
	#
	time += delta_ms

	is_onfloor = onfloor
	is_onwall = onwall
	is_moving_fast = movingfast
	is_falling =  (not is_onfloor) and velocity.y > 0
	is_mounting = (not is_onfloor) and velocity.y < 0
	is_moving = (abs(velocity.x) > 5.0) or (abs(velocity.y) > 5.0)
	is_idle = (abs(velocity.x) < 5.0)

	right_p = Input.is_action_pressed('ui_right')
	left_p = Input.is_action_pressed('ui_left')
	jump_jp = Input.is_action_just_pressed('ui_up')
	jump_jr = Input.is_action_just_released('ui_up')
	crouch_p = Input.is_action_pressed('ui_down')
	aim_jp = Input.is_action_just_pressed("ui_select")
	shoot_jr = Input.is_action_just_released("ui_select")
	dunk_p = Input.is_action_pressed("ui_accept")
	select_jp = Input.is_action_just_pressed("ui_select_alter")

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
	is_jumping = is_jumping and not is_onfloor and is_mounting
	is_walljumping = is_walljumping and not is_onfloor and is_mounting
	is_dunking = is_dunking and not is_onfloor # handle by player actions (start) and animation (stop but not yet implemented)
	is_halfturning = (is_halfturning or dir_sprite*direction_p == -1) and is_onfloor and direction_p != 0 and not is_shooting # handle by player actions
	is_landing = is_onfloor and not is_onwall and (is_landing or (time-last_onair < land_lag_tolerance)) and not is_halfturning# stop also handled by animation
	#is_crouching = # handle by player actions (start)
	is_aiming = is_aiming and has_ball and active_ball != null and not is_dunking
	#is_shooting handle by shoot animation+Player.gd


	can_jump = (time - last_onfloor < jump_lag_tolerance) \
			  and (time - last_jump > jump_countdown)
	can_walljump = (time - last_onwall < jump_lag_tolerance) \
		  and (time - last_jump > jump_countdown)
	can_go = (time - last_walljump > walljump_move_countdown)
	can_crouch = is_onfloor
	can_aim = (time - last_shoot > shoot_countdown) and has_ball and active_ball != null
	can_shoot = is_aiming and has_ball and active_ball != null
	can_dunk = not is_onfloor
