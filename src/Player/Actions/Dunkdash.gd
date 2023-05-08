extends Action

@export var up_distance_to_basket = 0#px
@export var can_go_delay = 0.2#s
@export var ghost_modulate : Color# (Color, RGBA)

var velocity_save = Vector2.ZERO
var dash_dir = Vector2.ZERO
var nb_quadrant = 8

func move(delta):
	print("begindash")
	# Change hitbox + other animation things like sliding etc.
	#	var anim = get_parent().get_parent().get_node("Sprite2D/AnimationTree3")
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunkdashing = true
	S.set_action(S.ActionType.DUNKDASH)

	#P.gravity = Vector2.ZERO
	P.remove_accel(Global.gravity_alterer)

	P.PlayerEffects.cloud_start()
	P.PlayerEffects.jump_start()
	if S.has_ball:
		P.PlayerEffects.ghost_start(0.21,0.05, Color.WHITE,S.active_ball.get_dash_gradient())
		S.active_ball.on_dunkdash_start(P)
	else:
		P.PlayerEffects.ghost_start(0.21,0.05, ghost_modulate)
	P.PlayerEffects.distortion_start("fast_soft",0.75)
	Global.camera.screen_shake(0.2,10)

	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.countdown_jump)
	S.get_node("CanGoTimer").start(can_go_delay)

	velocity_save = S.velocity

#	var q = (S.dunkdash_basket.position+up_distance_to_basket*Vector2.UP) - P.position
#	q *= -P.dunkdash_speed/q.length()
#	q.y = max(q.y, P.jump_speed)
#	P.get_out(P.global_position, q)

#	var corrected_angle = (S.dunkdash_basket.position - P.position).angle()
#	corrected_angle = correction_angle(corrected_angle)
#	dash_dir = Vector2.RIGHT.rotated(corrected_angle)
	var xx = (S.dunkdash_basket.global_position - P.global_position).x
	S.direction_sprite = 1 if (xx > 0) else ( -1 if (xx < 0) else 0)

	var dash_velocity = effective_dash_velocity(S.dunkdash_basket)
	if not S.is_grinding:
		P.get_out(P.global_position, dash_velocity)
	else :
		S.velocity = dash_velocity

func move_end():
	print("enddash")
	P.add_accel(Global.gravity_alterer) # TODO check if it is in an antigravity zone ?

	if not S.is_grinding:
		var temp_vel_l = S.velocity.length()
		var vel_dir = Vector2.ZERO
		if temp_vel_l != 0.0: #avoid zero division
			vel_dir = S.velocity/temp_vel_l # vel_dir is not always equals to dash_dir (e.g if there is an obstacle on the dash path)
		var temp_dot = velocity_save.dot(vel_dir)
		if 0.5*temp_vel_l > temp_dot :
			S.velocity *= 0.5
		else :
			S.velocity = temp_dot * vel_dir

		if S.direction_p * S.move_direction < 0:
			S.velocity.x *= 0.5 # again
	#P.get_node("Sprite2D").modulate = Color.WHITE

	if S.has_ball: # WARNING the ball can change during the dash!
		S.active_ball.on_dunkdash_end(P)

func correction_angle(x:float): # for a discrete dash angle
	var l = 2*PI/nb_quadrant
	var xp = x/l
	var n = int(round(xp)) % nb_quadrant # the number of the quadrant x is into
	var d = 2*(xp-n) # should be between -1 and 1
	return l*(pow(d,5)+n)

func effective_dash_velocity(target : Node2D):
	var q = (target.global_position - P.global_position)
	var ql = q.length()
	var target_dir = Vector2.UP # limit case when the player is exactly on the target
	if ql != 0.0:
		target_dir = 1.0/ql * q
	var dash_speed = max(P.dunkdash_speed, velocity_save.dot(target_dir))
	var target_velocity = target.get("linear_velocity")

	if target_velocity == null:
		return dash_speed * target_dir

	var dash_position = target.global_position + ql/dash_speed * target_velocity
	return dash_speed * (dash_position - P.global_position).normalized()
