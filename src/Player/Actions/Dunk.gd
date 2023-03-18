extends Action

var pos_tween : Tween
var dunking_basket = null

func _ready():
	pass

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
	dunking_basket = S.dunk_basket
	var dunk_position = dunking_basket.get_dunk_position(P.global_position)
	var xx = (dunk_position - P.global_position).x
	S.direction_sprite = 1 if (xx > 0) else ( -1 if (xx < 0) else 0)

	if pos_tween:

		pos_tween.kill()
	pos_tween = get_tree().create_tween()
	pos_tween.tween_property(P, "global_position",\
		dunk_position,0.32)\
		.set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	#pos_tween.start()
	if S.active_ball != null:
		S.active_ball.on_dunk(dunking_basket)
	#await get_tree().create_timer(0.32).timeout

# should be called by the animation
func move_dunk():
	# at this point, S.dunk_basket can be null
	assert(dunking_basket != null)
	# be careful, selected basket is sometimes null because the player got out of the zone...
	if S.active_ball != null:
		dunking_basket.dunk(P, S.active_ball)
	else :
		dunking_basket.dunk(P)

func test_print():
	print("Time : "+str(Time.get_ticks_msec()))


func move_hang():
	print("Hang")
	test_print()
	assert(dunking_basket != null)
	dunking_basket.get_hanged(P)

func move_end():
	pass
