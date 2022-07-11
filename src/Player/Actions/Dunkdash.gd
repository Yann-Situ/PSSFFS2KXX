extends Action

export var up_distance_to_basket = 0#px
export var can_go_delay = 0.2#s
export(Color, RGBA) var ghost_modulate

var velocity_save = Vector2.ZERO
var dash_dir = Vector2.ZERO
var nb_quadrant = 8

func move(delta):
	print("begindash")
	# Change hitbox + other animation things like sliding etc.
	#	var anim = get_parent().get_parent().get_node("Sprite/AnimationTree3")
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunkdashing = true
	S.set_action(S.ActionType.DUNKDASH)
	P.gravity = Vector2.ZERO

	P.PlayerEffects.cloud_start()
	P.PlayerEffects.jump_start()
	P.PlayerEffects.ghost_start(0.21,0.05, ghost_modulate)
	P.PlayerEffects.distortion_start("fast_soft", 0.75)
	P.get_node("Camera").screen_shake(0.2,10)

	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	S.get_node("CanGoTimer").start(can_go_delay)

	velocity_save = S.velocity

#	var q = (S.dunkdash_basket.position+up_distance_to_basket*Vector2.UP) - P.position
#	q *= -P.dunkdash_speed/q.length()
#	q.y = max(q.y, P.jump_speed)
#	P.get_out(P.global_position, q)
	var corrected_angle = (S.dunkdash_basket.position - P.position).angle()
	print(corrected_angle*180/PI)
	corrected_angle = correction_angle(corrected_angle)
	print(corrected_angle*180/PI)
	dash_dir = Vector2.RIGHT.rotated(corrected_angle)
	var q = max(P.dunkdash_speed, velocity_save.dot(dash_dir)) * dash_dir
	if not S.is_grinding:
		P.get_out(P.global_position, q)
	else :
		S.velocity = q
	#print("Velocity: "+str(S.velocity))

func move_end():
	print("enddash")
	P.gravity = P.based_gravity

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
	#P.get_node("Sprite").modulate = Color.white

func correction_angle(x:float):
	var l = 2*PI/nb_quadrant
	var xp = x/l
	var n = int(round(xp)) % nb_quadrant # the number of the quadrant x is into
	var d = 2*(xp-n) # should be between -1 and 1
	return l*(pow(d,5)+n)
