extends Action

func move(delta):
	S.is_aiming = true
	S.last_aim_jp = S.time
	P.Shooter.update_viewer_parameter(S.active_ball)
	P.Shooter.enable_screen_viewer()
	#Engine.time_scale = 0.5
