extends Action

export(Color, RGBA) var ghost_modulate
export (float) var dunkjumphalfturn_threshold
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
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	S.get_node("CanDunkjumpTimer").start(S.dunkjump_countdown)
	basket = S.dunkjump_basket
	S.is_dunkjumphalfturning = false
	if P.flip_h:
		direction = -1
	else:
		direction = 1
	
	P.PlayerEffects.ghost_start(0.8,0.08, ghost_modulate)
# called by animation
func move_jump():
	P.PlayerEffects.jump_start()
	if S.dunkjump_basket != null:
		basket = S.dunkjump_basket
	
	var q = basket.get_closest_point(P.global_position) - P.global_position
	var B = P.dunkjump_speed * q.x / q.y
	var C = -P.gravity.y * 0.5 * q.x*q.x/q.y
	var vox1 = 0.5*(B - sqrt(B*B-4*C))
	var vox2 = 0.5*(B + sqrt(B*B-4*C))
	if (abs(vox2) < abs(vox1)):
		S.velocity.x = vox2
	else :
		S.velocity.x = vox1
	S.velocity.y = P.dunkjump_speed
	S.is_dunkjumphalfturning = (q.x*direction < dunkjumphalfturn_threshold)
	#print("Velocity: "+str(S.velocity))
	P.get_node("Camera").screen_shake(0.2,10)

func move_end():
	pass
