extends PlayerMovementState

@export var no_side_delay = 0.2#s

@export_group("States")
@export var exit_state : State

var velocity_save = Vector2.ZERO
var dash_dir = Vector2.ZERO
var accel_alterer = AltererMultiplicative.new(0.0)

func _ready():
	animation_variations = [["dunkdash"], ["dunkdash_reverse"]] # [["animation_1", "animation_2"]]

func branch() -> State:
	if logic.belong.ing:
	 	return belong_state
	# if logic.action.can:
	# 	return action_state
	# TODO handle the end of the dash
	return self

func enter(previous_state : State = null) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state
	play_animation()

	logic.dunkdash.ing = true
	# logic.action.ing is already set in PlayerStatusLogic.gd
	logic.no_side_timer.start(no_side_delay)

	player.add_accel(accel_alterer)

	var target_node : Node2D = null
	if selectable_handler.has_selectable_dunkdash():
		target_node = selectable_handler.get_selectable_dunkdash().parent_node
	else:
		printerr("dunkdash but selectable_handler.has_selectable_dunkdash() returned false")
		return fall_state # or stand_state?

	var dash_velocity = anticipate_dash_velocity(target_node)
	movement.velocity = dash_velocity

	# TODO
	# if logic.has_ball:
	# 	logic.active_ball.on_dunkdash_start(P)
	# 	player.PlayerEffects.ghost_start(0.21,0.05, Color.WHITE,logic.active_ball.get_dash_gradient())
	# else:
	# 	player.PlayerEffects.ghost_start(0.21,0.05, ghost_modulate)
	# player.PlayerEffects.cloud_start()
	# player.PlayerEffects.jump_start()
	# player.PlayerEffects.distortion_start("fast_soft",0.75)
	# Global.camera.screen_shake(0.2,10)

	print(self.name)
	return next_state


## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	var next_state = branch()
	if next_state != self:
		return next_state

	# side_move_physics_process(delta) # no side during dunkdash

	# update player position
	if player.physics_enabled:
		movement_physics_process(delta)
	return self

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit():
	super()
	player.remove_accel(accel_alterer)
	logic.dunkdash.ing = false

	# TODO, translate this:
	# if not logic.is_grinding and not logic.is_hanging :
	# 	var temp_vel_l = logic.velocity.length()
	# 	var vel_dir = Vector2.ZERO
	# 	if temp_vel_l != 0.0: #avoid zero division
	# 		vel_dir = logic.velocity/temp_vel_l # vel_dir is not always equals to dash_dir (e.g if there is an obstacle on the dash path)
	# 	var temp_dot = velocity_save.dot(vel_dir)
	# 	if 0.5*temp_vel_l > temp_dot :
	# 		logic.set_velocity_safe(logic.velocity * 0.5)
	# 	else :
	# 		logic.set_velocity_safe(temp_dot * vel_dir)
	#
	# 	if logic.direction_p * logic.move_direction < 0:
	# 		logic.set_velocity_safe(Vector2(logic.velocity.x * 0.5, logic.velocity.y)) # again, so *0.25 when also match the first case
	#
	# if logic.has_ball: # WARNING the ball can change during the dash!
	# 	logic.active_ball.on_dunkdash_end(P)

## return the dash_velocity Vector2, taking into account the target_velocity
func anticipate_dash_velocity(target : Node2D, dunkdash_speed : float):
	var q = (target.global_position - player.global_position)
	var ql = q.length()
	var target_dir = Vector2.UP # limit case when the player is exactly on the target
	if ql != 0.0:
		target_dir = 1.0/ql * q
	var dash_speed = max(dunkdash_speed, velocity_save.dot(target_dir))
	var target_velocity = target.get("linear_velocity")

	if target_velocity == null: # if no velocity
		return dash_speed * target_dir

	var anticipated_position = target.global_position + ql/dash_speed * target_velocity
	return dash_speed * (anticipated_position - player.global_position).normalized()
