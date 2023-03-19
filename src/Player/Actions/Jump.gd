extends Action

func move(delta, jump_speed = 0.0):
	if jump_speed == 0.0:
		S.velocity.y = P.jump_speed
	else :
		S.velocity.y = jump_speed
		
	P.get_out(P.global_position, S.velocity)
	S.is_jumping = true
	S.get_node("ToleranceJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.countdown_jump)
	P.PlayerEffects.dust_start()
	P.PlayerEffects.jump_start()
