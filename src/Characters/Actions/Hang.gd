extends Action

func move(delta):
	print("ON_HANG")
	S.is_hanging = true

func move_stop():
	S.is_hanging = false
