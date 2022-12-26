extends Action

func move(delta):
	S.is_aiming = false
	S.aim_direction = 0
	S.is_shooting = true
	S.set_action(S.ActionType.SHOOT)
	S.get_node("CanShootTimer").start(S.shoot_countdown)
	P.ShootPredictor.shoot_vector_save = P.shoot#P.ShootPredictor.shoot_vector()
	S.direction_sprite = 1 if (P.shoot.x > 0) else ( -1 if (P.shoot.x < 0) else 0)
	#Engine.time_scale = 1.0
	P.ShootPredictor.clear()
	#shoot_ball+ throw_ball()+free_ball in Ball_handler are called by animation
	
func move_end():
	pass
