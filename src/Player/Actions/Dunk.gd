extends Action

var pos_tween

func _ready():
	pos_tween = Tween.new()
	pos_tween.name = "PosTween"
	add_child(pos_tween)
	
func move(delta):
	# Change hitbox + other animation things like sliding etc.
	# at this point, can_dunk is true so S.dunk_basket is not null
	P.get_out(P.global_position, Vector2.ZERO)
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunking = true
	S.set_action(S.ActionType.DUNK)
	S.get_node("CanDunkTimer").start(S.dunk_countdown)
	S.get_node("ToleranceDunkJumpPressTimer").stop() # no dunkjump just after
	#S.get_node("CanGoTimer").start(0.32)
	pos_tween.interpolate_property(P, "global_position", P.global_position, \
		S.dunk_basket.get_dunk_position(P.global_position), \
		0.32, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	pos_tween.start()
	if S.active_ball != null:
		S.active_ball.on_dunk()
	#yield(get_tree().create_timer(0.32), "timeout")
	
# should be called by the animation
func move_dunk():
	# at this point, S.dunk_basket can be null
	P.get_node("Camera").screen_shake(0.3,30)
	if S.dunk_basket != null:
		S.dunk_basket.dunk(P) # be careful, selected basket is sometimes null because the player got out of the zone...

func move_hang():
	if S.dunk_basket != null:
		S.dunk_basket.get_hanged(P)
