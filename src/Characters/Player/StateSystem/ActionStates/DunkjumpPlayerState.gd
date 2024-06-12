extends PlayerMovementState

@export var selectable_handler : SelectableHandler
@export var dunkjump_speed : float = 800.0 #: set = set_dunkjump_speed, get = get_dunkjump_speed ##
@export var dunkjumphalfturn_threshold : float = 32.0 ## minimum distance from the basket at which it is possible to do a dunkjump_halfturn
@export var min_jump_duration : float = 0.1 ## s # duration between the beginning of the jump to the first frame where land/fallwall/fall is possible

@export_group("States")
@export var belong_state : State
@export var dunk_state : State
@export var fallwall_state : State
@export var fall_state : State
@export var land_state : State

var min_duration_timer : Timer # time the duration between the beginning of the
# jump to the first frame where land/fallwall/fall is possible
var basket_at_enter : NewBasket = null
var position_tween : Tween
var is_dunkprejumping = true  # set to false at the end of animation ["dunkprejump"]
var is_dunkjumphalfturning = false # set at the end of the dunkprejump (see func dunkprejump_end)

func _ready():
	animation_variations = [["dunkjump"], ["dunkjump_halfturn"], ["dunkprejump","dunkjump"]] # [["animation_1", "animation_2"]]
	min_duration_timer = Timer.new()
	min_duration_timer.autostart = false
	min_duration_timer.one_shot = true
	min_duration_timer.wait_time = min_jump_duration
	add_child(min_duration_timer)

func branch() -> State:
	if logic.belong.ing:
		return belong_state
	if logic.dunk.can and logic.accept.pressed:
		return dunk_state

	if min_duration_timer.is_stopped():
		if logic.floor.ing:
			return land_state
		if logic.wall.ing:
			return fallwall_state
	# handle the end of the dunk
	# if end_dunkjump:
	# 	return fall_state
	return self

func enter(previous_state : State = null) -> State:
	# end_dunkjump = false
	is_dunkprejumping = true
	is_dunkjumphalfturning = false

	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()

	logic.dunkjump.ing = true
	# logic.no_jump_timer.start(no_jump_delay)
	# logic.jump_press_timer.stop() ## TODO see delays and stuff
	# logic.action.ing is already set in PlayerStatusLogic.gd

	if !selectable_handler.has_selectable_dunkjump():
		printerr("dunk but selectable_handler.has_selectable_dunkjump() returned false")
		return fall_state

	basket_at_enter = selectable_handler.get_selectable_dunkjumpdash().parent_node
	if !basket_at_enter is NewBasket:
		basket_at_enter = null
		printerr("dunk but selectable_handler.has_selectable_dunkjump().parent_node is not NewBasket")
		return fall_state

	var dunk_position = basket_at_enter.get_dunkjump_position(player.global_position)
	var dunk_dir_x = sign(dunk_position.x - player.global_position.x)
	player.set_flip_h(dunk_dir_x <0)
	logic.direction_sprite = -1 if dunk_dir_x < 0 else 1
	logic.direction_sprite_change.can = false

	if position_tween:
		position_tween.kill()
	position_tween = get_tree().create_tween()
	position_tween.set_parallel(false)
	position_tween.tween_property(player, "global_position",dunk_position,0.32)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#position_tween.start()

	# TODO
	# if P.flip_h:
	# S.is_dunkprejumping = true
	# P.PlayerEffects.dust_start()
	# basket = S.dunkjump_basket
	# S.is_dunkjumphalfturning = false
	# 	direction = -1
	# else:
	# 	direction = 1
	# S.direction_sprite = direction
	#
	# if S.has_ball:
	# 	P.PlayerEffects.ghost_start(0.8,0.1, Color.WHITE,S.active_ball.get_dash_gradient())
	# else:
	# 	P.PlayerEffects.ghost_start(0.8,0.1, ghost_modulate)

	print(self.name)
	return next_state

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# side_move_physics_process(delta) # no side during dunk

	# update player position
	# if player.physics_enabled:
	# 	movement_physics_process(delta) # no movement during dunk
	return self

## should be called by animation (end of dunkprejump) at physics frame # WARNING
func dunkprejump_end():
	is_dunkprejumping = false

	## TODO do the jump: # change gravity stuff
	# P.PlayerEffects.jump_start()
	if basket_at_enter == null :
		push_warning("basket_at_enter is null at the end of dunkprejumping")

	var q = basket_at_enter.get_closest_point(player.global_position) - player.global_position
	var dunk_dir_x = sign(q.x)
	player.set_flip_h(dunk_dir_x <0)
	logic.direction_sprite = -1 if dunk_dir_x < 0 else 1

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

	is_dunkjumphalfturning = (q.x*logic.direction_sprite < dunkjumphalfturn_threshold)
	Global.camera.screen_shake(0.2,10)

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	logic.dunkjump.ing = false
	logic.direction_sprite_change.can = true
	if position_tween:
		position_tween.kill()
	#	if logic.has_ball: # WARNING the ball can change during the dunk!
	#		logic.active_ball.on_dunkjump_end(P)
