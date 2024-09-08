extends Action

func move(delta):
	if S.move_direction != 0 and S.move_direction != S.direction_p: # if not moving in the same dir as input
		if S.is_onfloor:
			#S.velocity.x = lerp(S.velocity.x, 0, P.floor_friction)
			S.velocity.x = GlobalMaths.apply_friction(S.velocity.x, P.floor_friction, delta)
		else : #in the air
			#S.velocity.x = lerp(S.velocity.x, 0, P.air_friction)
			S.velocity.x = GlobalMaths.apply_friction(S.velocity.x, P.air_friction, delta)
