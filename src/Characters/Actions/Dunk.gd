extends Action

func move(delta):
	# Change hitbox + other animation things like sliding etc.
	S.is_dunking = true
	S.is_dunkjumping = false
	S.velocity.x = 0
	S.velocity.y = 0
	S.get_node("CanDunkTimer").start(S.dunk_countdown)
	S.get_node("CanGoTimer").start(0.3)
	yield(get_tree().create_timer(0.3), "timeout")
	#P.get_node("Camera").screen_shake(0.3,30)
	S.dunk_basket.dunk() # be careful, selected basket is sometimes null because the player got out of the zone...