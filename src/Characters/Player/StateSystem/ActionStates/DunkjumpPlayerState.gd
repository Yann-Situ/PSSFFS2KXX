extends PlayerMovementState

@export var selectable_handler : SelectableHandler
@export var dunkjump_speed : float = -500.0 #: set = set_dunkjump_speed, get = get_dunkjump_speed ##
@export var dunkjumphalfturn_threshold : float = 16.0 ## minimum distance from the basket at which it is possible to do a dunkjump_halfturn
@export var min_jump_duration : float = 0.1 ## s # duration between the beginning of the jump (just after prejumping) to the first frame where land/fallwall/fall is possible.
@export var ghost_modulate : Color# (Color, RGBA)

@export_group("States")
@export var belong_state : State
@export var dunk_state : State
@export var fallwall_state : State
@export var fall_state : State
@export var land_state : State

var min_duration_timer : Timer # time the duration between the beginning of the
# jump to the first frame where land/fallwall/fall is possible
var basket_at_enter : NewBasket = null
var is_dunkprejumping = true  # set to false at the end of animation ["dunkprejump"]
var is_dunkjumphalfturning = false # set at the end of the dunkprejump (see func dunkprejump_end)
var dunkjump_movement_to_call = false

func _ready():
	animation_variations = [["dunkprejump"], ["dunkjump"], ["dunkjump_halfturn"], ["dunkprejump","dunkjump"]] # [["animation_1", "animation_2"]]
	min_duration_timer = Timer.new()
	min_duration_timer.autostart = false
	min_duration_timer.one_shot = true
	min_duration_timer.wait_time = min_jump_duration
	add_child(min_duration_timer)

func branch() -> State:
	if logic.belong_ing:
		return belong_state
	if logic.dunk.can and logic.accept.pressed:
		return dunk_state

	if !is_dunkprejumping and min_duration_timer.is_stopped():
		if logic.floor.ing and player.movement.velocity.y >= 0.0:
			return land_state
		if logic.wall.ing:
			return fallwall_state
	# handle the end of the dunk
	# if end_dunkjump:
	# 	return fall_state
	return self

func enter(previous_state : State = null) -> State:
	is_dunkprejumping = true
	is_dunkjumphalfturning = false
	dunkjump_movement_to_call = false

	var next_state = branch()
	if next_state != self:
		return next_state
	set_variation(0) # dunkprejump
	play_animation()

	logic.dunkjump.ing = true
	logic.direction_sprite_change.can = false
	# logic.no_jump_timer.start(no_jump_delay)
	# logic.jump_press_timer.stop() ## TODO see delays and stuff
	# logic.action.ing is already set in PlayerStatusLogic.gd

	if !selectable_handler.has_selectable_dunkjump():
		printerr("dunk but selectable_handler.has_selectable_dunkjump() returned false")
		return fall_state

	basket_at_enter = selectable_handler.get_selectable_dunkjump().parent_node
	if !basket_at_enter is NewBasket:
		basket_at_enter = null
		printerr("dunk but selectable_handler.has_selectable_dunkjump().parent_node is not NewBasket")
		return fall_state

	#var dunk_position = basket_at_enter.get_closest_point(player.global_position)
	#var dunk_dir_x = sign(dunk_position.x - player.global_position.x)
	#player.set_flip_h(dunk_dir_x <0)
	#logic.direction_sprite = -1 if dunk_dir_x < 0 else 1

	# effects
	player.effect_handler.cloud_start(12)
	Global.camera.screen_shake(0.1,6)
	GodotParadiseGeneralUtilities.frame_freeze(0.2, 0.2)

	print(self.name)
	return next_state

#func animation_process() -> void:
	#if is_dunkjumphalfturning:
		#set_variation(1) # ["halfturningdunkjump"]
	#else:
		#set_variation(0) # ["classic"]
	#play_animation() # without priority

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	if dunkjump_movement_to_call:
		dunkjump_movement()
		dunkjump_movement_to_call = false

	# side_move_physics_process(delta) # no side during dunk

	# update player position
	if player.physics_enabled:
		if is_dunkprejumping:
			movement.velocity = Vector2.ZERO
		else:
			delta *= movement.ambient.time_scale
			# apply alterables
			apply_force_alterable(delta, movement)
			apply_accel_alterable(delta, movement)
			# move and slide
			apply_speed_alterable(delta, movement)
			player.set_velocity(movement.velocity)
			player.move_and_slide()	# update player position
			movement.velocity = player.get_real_velocity()-movement.speed_alterable.get_value()
	return self

## should be called by animation (end of dunkprejump)
func dunkprejump_end():
	is_dunkprejumping = false
	min_duration_timer.start()
	dunkjump_movement_to_call = true

## should be called at physics frame # WARNING
func dunkjump_movement():
	# effects
	if logic.ball_handler.has_ball():
		var ball = logic.ball_handler.held_ball
		ball.on_dunkjump_start(player)
		player.effect_handler.ghost_start(0.8,0.1, Color.WHITE,ball.get_dash_gradient())
	else:
		player.effect_handler.ghost_start(0.8,0.1, ghost_modulate)
	# GlobalEffect.make_distortion(player.effect_handler.global_position, 0.75, "fast_soft")
	GlobalEffect.make_ground_wave(player.effect_handler.global_position, 0.75, "soft")
	player.effect_handler.dust_start()
	GlobalEffect.make_impact(player.effect_handler.global_position, \
		GlobalEffect.IMPACT_TYPE.JUMP1, Vector2.UP)
	
	if basket_at_enter == null :
		push_warning("basket_at_enter is null at the end of dunkprejumping")

	var q = basket_at_enter.get_closest_point(player.global_position) - player.global_position
	
	var dunk_dir_x = sign(q.x)
	logic.direction_sprite_change.can = true
	player.set_flip_h(dunk_dir_x <0)
	is_dunkjumphalfturning = (q.x*logic.direction_sprite < -dunkjumphalfturn_threshold)
	if is_dunkjumphalfturning:
		set_variation(2)
	else:
		set_variation(1)
	play_animation() # bof, better if it is called in process frame, more consistent...
	logic.direction_sprite = -1 if dunk_dir_x < 0 else 1
	logic.direction_sprite_change.can = false
	
	if q.y == 0.0:
		movement.velocity.x = -0.5*q.x*Global.default_gravity.y/dunkjump_speed
	else : # standard case
		var B = dunkjump_speed * q.x / q.y
		var C = -Global.default_gravity.y * 0.5 * q.x*q.x/q.y
		var sq_discriminant = B*B-4*C

		if sq_discriminant < 0.0: # should not happen
			movement.velocity.x = -0.5*q.x*Global.default_gravity.y/dunkjump_speed
		else:
			sq_discriminant = sqrt(sq_discriminant)
			var velocity_x1 = 0.5*(B - sq_discriminant)
			var velocity_x2 = 0.5*(B + sq_discriminant)
			if (abs(velocity_x2) < abs(velocity_x1)):
				movement.velocity.x = velocity_x2
			else :
				movement.velocity.x = velocity_x1
	movement.velocity.y = dunkjump_speed
	Global.camera.screen_shake(0.2,10)

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.dunkjump.ing = false
	logic.direction_sprite_change.can = true
#	if logic.has_ball: # WARNING the ball can change during the dunk!
#		logic.active_ball.on_dunkjump_end(P)
