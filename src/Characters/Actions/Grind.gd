extends Action

func move(delta):
	print("ON_GRIND")
	S.is_grinding = true

func move_stop():
	S.is_grinding = false
