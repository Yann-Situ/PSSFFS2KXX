extends Action

enum DUNKJUMP_TYPE {HIGH_JUMP, AGRESSIVE}
export (DUNKJUMP_TYPE) var dunkjump_type
export(Color, RGBA) var ghost_modulate
var basket = null

func move(delta):
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunkjumping = true
	S.is_dunkprejumping = true
	P.PlayerEffects.dust_start()
	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	basket = S.dunkjump_basket
	S.velocity = Vector2.ZERO
	
# called by animation
func move_jump():
	P.PlayerEffects.jump_start()
	P.PlayerEffects.ghost_start(0.5,0.065, ghost_modulate)
	if S.dunkjump_basket != null:
		basket = S.dunkjump_basket
	if dunkjump_type == DUNKJUMP_TYPE.HIGH_JUMP :
		var q = basket.position - P.position
		var B = P.dunk_speed * q.x / q.y
		var C = -P.gravity * 0.5 * q.x*q.x/q.y
		var vox1 = 0.5*(B - sqrt(B*B-4*C))
		var vox2 = 0.5*(B + sqrt(B*B-4*C))
		if (abs(vox2) < abs(vox1)):
			S.velocity.x = vox2
		else :
			S.velocity.x = vox1
		S.velocity.y = P.dunk_speed
	elif dunkjump_type == DUNKJUMP_TYPE.AGRESSIVE :
		var q = (basket.position+32*Vector2.UP) - P.position
		S.velocity = -P.dunk_speed * q.normalized()
	#print("Velocity: "+str(S.velocity))
	P.get_node("Camera").screen_shake(0.2,10)

