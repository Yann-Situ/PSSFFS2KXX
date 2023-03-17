extends Action

@onready var pos_tween = get_tree().create_tween()

func _ready():
	pass

func move(delta):
	# Change hitbox + other animation things like sliding etc.
	S.is_dunking = true
	S.is_dunkjumping = false
	S.velocity.x = 0
	S.velocity.y = 0

	S.get_node("CanDunkTimer").start(S.dunk_countdown)
	pos_tween.kill()
	pos_tween = get_tree().create_tween()
	pos_tween.tween_property(P, "global_position",\
		S.dunk_basket.get_dunk_position(P.global_position),0.32)\
		.set_trans(Tween.TRANS_LINEAR)
	#pos_tween.start()
	if S.held_ball != null:
		S.held_ball.on_dunk()

	await get_tree().create_timer(0.32).timeout

	# at this point, S.dunk_basket can be null
	#P.get_node("Camera").screen_shake(0.3,30)
	S.dunk_basket.dunk(P) # be careful, selected basket is sometimes null because the player got out of the zone...
