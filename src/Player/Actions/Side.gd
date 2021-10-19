extends Action

func move(delta,direction_p):
	if S.is_onfloor :
		if S.is_crouching :
			if (S.velocity.x*direction_p > P.crouch_speed_max) :
				pass # in the same direction_p as velocity and faster than max
			else :
				S.velocity.x += direction_p*P.crouch_accel*delta
				if (S.velocity.x*direction_p > P.crouch_speed_max) :
					S.velocity.x = direction_p*P.crouch_speed_max
					
			if -P.crouch_return_thresh_instant_speed < S.velocity.x*direction_p \
				and S.velocity.x*direction_p < P.crouch_instant_speed :
				S.velocity.x = direction_p*P.crouch_instant_speed
		else : #standing on the floor, maybe moving
			if (S.velocity.x*direction_p >= P.run_speed_max) :
				pass # in the same direction_p as velocity and faster than max
			else :
				S.velocity.x += direction_p*P.walk_accel*delta
				if (S.velocity.x*direction_p > P.run_speed_max) :
					S.velocity.x = direction_p*P.run_speed_max

			if -P.walk_return_thresh_instant_speed < S.velocity.x*direction_p \
				and S.velocity.x*direction_p < P.walk_instant_speed :
				S.velocity.x = direction_p*P.walk_instant_speed
	else : # is in the air
		if (S.velocity.x*direction_p >= P.sideaerial_speed_max) :
			pass
		else :
			S.velocity.x += direction_p * P.sideaerial_accel * delta
			if (S.velocity.x*direction_p > P.sideaerial_speed_max) :
				S.velocity.x = direction_p * P.sideaerial_speed_max
		if -P.air_return_thresh_instant_speed < S.velocity.x*direction_p \
			and S.velocity.x*direction_p < P.air_instant_speed :
				S.velocity.x = direction_p*P.air_instant_speed
