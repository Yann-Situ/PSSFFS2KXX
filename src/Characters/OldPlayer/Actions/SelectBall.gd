extends Action

func move(delta):
	assert(Global.mouse_ball != null)
	if S.selected_ball != Global.mouse_ball :
		if S.power_p:
			S.selected_ball.power_jr(self,delta)
		Global.mouse_ball.select(P)
	else : #S.selected_ball == Global.mouse_ball
		S.selected_ball.deselect(P)
