extends Action

var b = true

func move(delta):
	# Change hitbox + other animation things like sliding etc.
	S.is_dunkjumping = true
	P.Effects.dust_start()
	P.Effects.ghost_start(0.35,0.07)
	P.Effects.jump_start()
	#print(S.dunkjump_basket)
	var q = S.dunkjump_basket.position - P.position
	var B = P.dunk_speed * q.x / q.y
	var C = -P.gravity * 0.5 * q.x*q.x/q.y
	var vox1 = 0.5*(B - sqrt(B*B-4*C))
	var vox2 = 0.5*(B + sqrt(B*B-4*C))
	if (abs(vox2) < abs(vox1)):
		S.velocity.x = vox2
	else :
		S.velocity.x = vox1
	S.velocity.y = P.dunk_speed
	print("Velocity: "+str(S.velocity))
	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	#P.get_node("Camera3D").screen_shake(0.2,10)
