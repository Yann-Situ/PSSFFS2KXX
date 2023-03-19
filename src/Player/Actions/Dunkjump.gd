extends Action

@export var ghost_modulate : Color# (Color, RGBA)
@export var dunkjumphalfturn_threshold : float
var basket = null
var direction = 0

func move(delta):
	# Change hitbox + other animation things like sliding etc.
	P.get_out(P.global_position, Vector2.ZERO)
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunkjumping = true
	S.is_dunkprejumping = true
	S.set_action(S.ActionType.DUNKJUMP)
	P.PlayerEffects.dust_start()
	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.countdown_jump)
	S.get_node("CanDunkjumpTimer").start(S.countdown_dunkjump)
	basket = S.dunkjump_basket
	S.is_dunkjumphalfturning = false
	if P.flip_h:
		direction = -1
	else:
		direction = 1
	S.direction_sprite = direction


	if S.has_ball:
		P.PlayerEffects.ghost_start(0.8,0.1, Color.WHITE,S.active_ball.get_dash_gradient())
	else:
		P.PlayerEffects.ghost_start(0.8,0.1, ghost_modulate)
# called by animation
func move_jump():
	P.PlayerEffects.jump_start()
	if S.dunkjump_basket != null:
		basket = S.dunkjump_basket

	var q = basket.get_closest_point(P.global_position) - P.global_position
	S.direction_sprite = 1 if (q.x > 0) else ( -1 if (q.x < 0) else 0)

	if q.y == 0.0:
		S.velocity.x = -0.5*q.x*P.gravity.y/P.dunkjump_speed
	else : # standard case
		var B = P.dunkjump_speed * q.x / q.y
		var C = -P.gravity.y * 0.5 * q.x*q.x/q.y
		var sq_discriminant = B*B-4*C

		if sq_discriminant < 0.0: # should not happen
			#TODO implement this case ?
			S.velocity.x = -0.5*q.x*P.gravity.y/P.dunkjump_speed
		else:
			sq_discriminant = sqrt(sq_discriminant)
			var velocity_x1 = 0.5*(B - sq_discriminant)
			var velocity_x2 = 0.5*(B + sq_discriminant)
			if (abs(velocity_x2) < abs(velocity_x1)):
				S.velocity.x = velocity_x2
			else :
				S.velocity.x = velocity_x1
	S.velocity.y = P.dunkjump_speed
	S.is_dunkjumphalfturning = (q.x*direction < dunkjumphalfturn_threshold)
	#print("Velocity: "+str(S.velocity))
	Global.camera.screen_shake(0.2,10)

func move_end():
	pass
