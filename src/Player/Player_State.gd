extends Node

@onready var player = get_parent()
@onready var actions = player.get_node("Actions")

var frame_time_ms = 1.0/60.0 #s
var time = 0.0#s

# Countdowns and delays between actions
@export_group("Timers management")
@export_subgroup("Tolerance delays", "tolerance_")
@export var tolerance_jump_floor : float = 7*frame_time_ms #s
@export var tolerance_jump_press : float = 7*frame_time_ms #s
@export var tolerance_wall_jump : float = 7*frame_time_ms #s
@export var tolerance_land_lag : float = 3*frame_time_ms #s

@export_subgroup("Countdown delays", "countdown_")
@export var countdown_walljump_move : float = 22*frame_time_ms #s
@export var countdown_jump : float = 10*frame_time_ms #s
@export var countdown_dunkjump : float = 0.4#s
@export var countdown_dunk : float = 0.9 #s
@export var countdown_shoot : float = 30*frame_time_ms #s

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
var is_onfloor = false # from values of player.gd
var is_onwall = false # from values of player.gd
var is_moving_fast = false # from values of player.gd
var is_falling = false
var is_mounting = false
var is_moving = false
var is_idle = false

# Delays and states memory # handle by player.gd
var last_frame_onair = false
var last_wall_normal_direction = 0 # handle by player.gd
var last_onair_velocity_y = 0
var last_aim_jp = 0 # still used for shoot vector

# Bool for actions
@export_group("actions flags")
@export var is_jumping = false
@export var is_walljumping = false
@export var is_landing = false
@export var is_landing_roll = false
@export var is_dunkjumping = false
@export var is_dunkprejumping = false
@export var is_dunkdashing = false
@export var is_dunking = false
@export var is_halfturning = false
@export var is_crouching = false
@export var is_aiming = false
@export var is_shooting = false
@export var is_sliding = false

@export var is_grinding = false
@export var is_hanging = false

var is_non_cancelable = false
var is_dunkjumphalfturning = false
enum ActionType { NONE, SHOOT, DUNK, DUNKDASH, DUNKJUMP }
var action_type = ActionType.NONE

# Bool var
@export var has_ball = false
var active_ball : Ball = null#pointer to a ball
var released_ball : Ball  = null # useful because when the ball is released (or thrown), it is immediatly detected by area_body_enter...
var selected_ball : Ball  = null#pointer to the selected ball
var dunkjump_basket = null#pointer to the basket to dunkjump
var dunkdash_basket = null#pointer to the basket to dunkdash
var shoot_basket = null#pointer to the basket to shoot
var dunk_basket = null

# Utilities
var move_direction : int = 0
var direction_p : int = 0
var direction_sprite : int = 0
var aim_direction : int = 0
var velocity = Vector2() : set = set_velocity
func set_velocity(v : Vector2):
	if player._zero_velocity_workaround :
		velocity = v
	else:
		# Here there was some weird behaviour: velocity is set to (0,0) each frame when the animationTree is activated
		# It seemed to be fixed by Godot 4.1
		push_warning("unauthorized access to state.velocity : "+str(v))
		pass
func set_velocity_safe(v : Vector2):
	var save = player._zero_velocity_workaround
	player._zero_velocity_workaround = true
	set_velocity(v)
	player._zero_velocity_workaround = save


func _ready():
	reset_state()

const CurrentStance = "parameters/cancelable/stance/stancetransition/transition_request"
const GrindBlend = "parameters/cancelable/stance/grind/blend_position"
func update_animationtree_stance():
	if is_hanging:
		player.animation_tree[CurrentStance] = "hang"#Stance.HANG
	elif is_grinding:
		player.animation_tree[CurrentStance] = "grind"#Stance.GRIND
		var dir = self.velocity
		if dir.x < 0:
			dir.x = -dir.x
		player.animation_tree[GrindBlend] = 0.2*round(-dir.angle() * (12.0/PI))
	elif not is_onfloor:
		player.animation_tree[CurrentStance] = "air"#Stance.AIR
	else : # S.is_onfloor
		player.animation_tree[CurrentStance] = "ground"#Stance.GROUND

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

func update_physical_states():
	player.SpecialActionHandler.update_space_state()
	is_onfloor = player.SpecialActionHandler.is_on_floor()
	is_onwall = player.SpecialActionHandler.is_on_wall()
	is_moving_fast = (abs(velocity.x) > player.walk_speed_moving_fast_thresh)
	is_falling =  (not is_onfloor) and velocity.y > 0
	is_mounting = (not is_onfloor) and velocity.y < 0
	is_moving = (abs(velocity.x) > 10.0) or (abs(velocity.y) > 10.0)
	#is_idle = (abs(velocity.x) <= 10.0)
	is_idle = direction_p == 0 # enable to slide on ice

func set_action(v): # for non_cancelable actions
	is_shooting = is_shooting and v == ActionType.SHOOT
	is_dunkdashing = is_dunkdashing and v == ActionType.DUNKDASH
	is_dunking = is_dunking and v == ActionType.DUNK
	is_dunkjumping = is_dunkjumping and v == ActionType.DUNKJUMP
	is_dunkprejumping = is_dunkprejumping and v == ActionType.DUNKJUMP

	if action_type != v:
		match action_type:
			ActionType.SHOOT:
				actions.get_node("Shoot").move_end()
			ActionType.DUNKDASH:
				print("set_action : "+str(v))
				actions.get_node("Dunkdash").move_end()
			ActionType.DUNK:
				actions.get_node("Dunk").move_end()
			ActionType.DUNKJUMP:
				actions.get_node("Dunkjump").move_end()
			_:
				pass

	action_type = v
	is_non_cancelable = action_type != ActionType.NONE

func update_non_cancelables():
	#is_shooting = is_shooting
	#is_dunking = is_dunking
	is_dunkdashing = is_dunkdashing# and not is_onfloor and dunk_p
	is_dunkprejumping = is_dunkprejumping and !(is_dunking or is_dunkdashing)
	is_dunkjumping = (is_dunkjumping  and \
		!(is_onfloor or (is_onwall and is_falling) or is_dunking or \
			is_dunkdashing or is_hanging or is_grinding)) or \
		is_dunkprejumping

	# update non_cancelable actions with the following priority
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

func update_action_permissions():
	can_jump = (not $ToleranceJumpFloorTimer.is_stopped() or is_grinding or \
		is_hanging) and $CanJumpTimer.is_stopped()
	can_walljump = not $ToleranceWallJumpTimer.is_stopped() and \
		$CanJumpTimer.is_stopped()
	can_go = $CanGoTimer.is_stopped() and not (is_dunkjumping and dunk_p) and \
		not is_dunkdashing and not is_dunking
	can_crouch = is_onfloor
	can_stand = player.SpecialActionHandler.can_stand()
	can_grind = !is_hanging and !is_dunking
	can_hang = true

	player.SpecialActionHandler.update_basket_selectors()
	can_aim = $CanShootTimer.is_stopped() and has_ball and active_ball != null and not is_dunking
	can_shoot = is_aiming and has_ball and active_ball != null
	can_dunkdash = player.SpecialActionHandler.can_dunkdash()
	can_dunkjump = player.SpecialActionHandler.can_dunkjump()
	can_dunk = $CanDunkTimer.is_stopped() and ((not is_onfloor and dunk_p)) and \
		not is_shooting and \
		not is_dunkprejumping and player.SpecialActionHandler.can_dunk()
		# TODO: enable dunking while hanging except when hanging on the dunk_basket

func update_cancelables():
	var actual_direction_sprite = 1;
	if self.get_parent().flip_h :
		actual_direction_sprite = -1;

	is_jumping = is_jumping and not is_onfloor and is_mounting and not is_dunkdashing
	is_walljumping = is_walljumping and is_jumping
	is_crouching = (is_onfloor and is_crouching) or not can_stand# handle by player actions (start)

	is_hanging = is_hanging and !crouch_p
	is_grinding = is_grinding and !is_hanging and !crouch_p

	is_landing = is_onfloor and not is_onwall and (is_landing or \
		(last_frame_onair and last_onair_velocity_y > player.landing_velocity_thresh)) and \
		not is_non_cancelable# stop also handled by animation
	is_landing_roll = is_landing and (abs(velocity.x) > 100.0)
	is_halfturning = (is_halfturning or actual_direction_sprite*direction_p == -1) and \
		is_onfloor and !(is_idle or direction_p == 0 or is_crouching or is_landing or \
			is_onwall or is_non_cancelable) # handle by player actions
	is_aiming = is_aiming and has_ball and active_ball != null and not is_non_cancelable

	is_sliding = is_sliding and is_crouching and crouch_p and not is_idle

func update_vars(delta):
	#
	# Delays and states memory should be updated after calling update_vars()
	# in player.gd
	#
	time += delta # TODO still used in the current shoot vector implementation... to change

	last_frame_onair = not is_onfloor

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

	# physical states:
	update_physical_states()
	# non-cancelables:
	update_non_cancelables()
	# possibilities can_*:
	update_action_permissions()
	# cancelables:
	update_cancelables()

	# direction_sprite and update the animationTree for stances:
	if !is_non_cancelable:
		if is_grinding or is_hanging or !can_go:
			direction_sprite = move_direction
		elif is_sliding:
			direction_sprite = 0
		else :
			direction_sprite = direction_p
		update_animationtree_stance()

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
	direction_sprite = 0
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
	is_sliding = false
	is_grinding = false
	is_hanging = false

	is_non_cancelable = false
	is_dunkjumphalfturning = false

	#has_ball = false
	#active_ball = null
	released_ball = null
	#selected_ball = null
	dunkjump_basket = null
	dunkdash_basket = null
	shoot_basket = null
	dunk_basket = null
