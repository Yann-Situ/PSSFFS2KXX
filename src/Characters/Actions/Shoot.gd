extends Action

func move(delta):
	S.is_shooting = true
	S.get_node("CanShootTimer").start(S.shoot_countdown)
	#P.ShootPredictor.shoot_vector_save = P.ShootPredictor.shoot_vector()
	#Engine.time_scale = 1.0
	#P.ShootPredictor.clear()
	#throw_ball()+free_ball in Ball_handler	called by animation

	# to do : handle shoot and direction
