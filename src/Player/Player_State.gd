extends Node

var frame_time_ms = 1000/60 #ms
export var time = 0 #ms

# Countdowns and delays between actions
export (float) var jump_lag_tolerance = 8*frame_time_ms #ms
export (float) var walljump_move_countdown = 22*frame_time_ms #ms
export (float) var jump_countdown = 10*frame_time_ms #ms
export (float) var shoot_countdown = 30*frame_time_ms #ms

# Bool for inputs ('p' is for 'pressed', 'jp' 'just_pressed', 'jr' 'just_released')
var right_p = false
var left_p = false
var jump_jp = false
var jump_jr = false
var crouch_p = false
var aim_jp = false
var shoot_jr = false

# Bool for physical states
var is_onfloor = false # handle by Player.gd
var is_onwall = false # handle by Player.gd
var is_falling = false
var is_mounting = false
var is_moving = false
var is_idle = false
var is_moving_fast = false # handle by Player.gd
#var is_slowing = false
#var is_speeding = false

# Bool for action permission
var can_jump = false
var can_walljump = false
var can_go = false
var can_crouch = false
var can_aim = false
var can_shoot = false

# Utilities
export var move_direction = 0
var direction_p = 0
var aim_direction = 0
var velocity = Vector2()

# Delays and states memory # handle by Player.gd
var last_onfloor = 0
var last_onwall = 0
var last_jump = 0
var last_walljump = 0
var last_wall_normal_direction = 0 # handle by Player.gd
var last_shoot = 0
var last_aim_jp = 0

# Bool for actions
export var is_jumping = false
export var is_walljumping = false
#export var is_going = [false,false]
export var is_returning = [false,false]
export var is_crouching = false
export var is_aiming = false # handle by Player.gd
export var is_shooting = false # handle by shoot animation+Player.gd

# Bool var
export var has_ball = false
var active_ball = null#pointer to a ball

func update_vars(delta_ms):
	time += delta_ms
	right_p = Input.is_action_pressed('ui_right')
	left_p = Input.is_action_pressed('ui_left')
	jump_jp = Input.is_action_just_pressed('ui_up')
	jump_jr = Input.is_action_just_released('ui_up')
	crouch_p = Input.is_action_pressed('ui_down')
	aim_jp = Input.is_action_just_pressed("ui_select")
	shoot_jr = Input.is_action_just_released("ui_select")
	
	if Input.is_action_just_pressed("ui_accept"):
		get_parent().get_node("Camera").screen_shake(0.2,5)
	
	#is_onfloor = (is_on_floor) # changed by PlatformPlayer
	#is_onwall  = (is_on_wall)  # changed by PlatformPlayer
	is_falling =  (not is_onfloor) and velocity.y > 0
	is_mounting = (not is_onfloor) and velocity.y < 0
	is_moving = (abs(velocity.x) > 5.0) or (abs(velocity.y) > 5.0)
	is_idle = (abs(velocity.x) < 5.0)
	#is_moving_fast[0] = (velocity.x < -walk_instant_speed)
	#is_moving_fast[1] = (velocity.x > walk_instant_speed)
	
	if (velocity.x == 0):
		move_direction = 0
	elif (velocity.x < 0):
		move_direction = -1
	else :
		move_direction = 1

	is_jumping = is_jumping and not is_onfloor and is_mounting
	is_walljumping = is_walljumping and not is_onfloor and is_mounting
	#is_going[0] = is_going[0] and is_moving_fast[0]
	#is_going[1] = is_going[1] and is_moving_fast[1]
	is_crouching = is_crouching and not is_jumping
	is_aiming = is_aiming and has_ball and active_ball != null
	
	direction_p = 0
	if right_p :
		direction_p += 1
	if left_p :
		direction_p -= 1
		
	can_jump = (time - last_onfloor < jump_lag_tolerance) \
			  and (time - last_jump > jump_countdown)
	can_walljump = (time - last_onwall < jump_lag_tolerance) \
		  and (time - last_jump > jump_countdown)
	can_go = (time - last_walljump > walljump_move_countdown)
	can_crouch = is_onfloor
	can_aim = (time - last_shoot > shoot_countdown) and has_ball and active_ball != null
	can_shoot = is_aiming and has_ball and active_ball != null
