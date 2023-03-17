extends Action

func move(delta):
	S.is_grinding = true
	P.PlayerEffects.grind_start()

func move_stop():
	S.is_grinding = false
	P.PlayerEffects.grind_stop()
	
