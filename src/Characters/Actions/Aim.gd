extends Action

func move(delta):
	S.is_aiming = true
	S.last_aim_jp = S.time
	#Engine.time_scale = 0.5
