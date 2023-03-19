extends Action

func move(delta,direction):
	S.velocity.x = -P.walljump_direction.x * direction * P.jump_speed
	S.velocity.y = -P.walljump_direction.y * P.jump_speed
	S.is_walljumping = true
	S.is_jumping = true
	S.get_node("ToleranceJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.countdown_jump)
	S.get_node("CanGoTimer").start(S.countdown_walljump_move)
	P.PlayerEffects.dust_start()
