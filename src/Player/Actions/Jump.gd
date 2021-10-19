extends Action

func move(delta):
	S.velocity.y = P.jump_speed
	S.is_jumping = true
	S.get_node("ToleranceJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	P.PlayerEffects.dust_start()
