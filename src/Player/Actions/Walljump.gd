extends Action

func move(delta,direction):
	S.velocity.x = -P.vec_walljump.x * direction * P.jump_speed
	S.velocity.y = -P.vec_walljump.y * P.jump_speed
	S.is_walljumping = true
	S.get_node("ToleranceJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	S.get_node("CanGoTimer").start(S.walljump_move_countdown)
	P.PlayerEffects.dust_start()
