extends Action

func move(delta):
	if S.selected_ball == null:
		S.selected_ball = Global.mouse_ball
		S.selected_ball.Highlighter.toggle_selection(true)
	elif S.selected_ball != Global.mouse_ball :
		S.selected_ball.Highlighter.toggle_selection(false)
		if S.power_p:
			S.selected_ball.power_jr(self,delta)
		S.selected_ball = Global.mouse_ball
		S.selected_ball.Highlighter.toggle_selection(true)
	else : #S.selected_ball == Global.mouse_ball
		S.selected_ball.Highlighter.toggle_selection(false)
		if S.power_p:
			S.selected_ball.power_jr(self,delta)
		S.selected_ball = null
