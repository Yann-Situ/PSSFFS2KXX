extends Action

export var up_distance_to_basket = 0#px
export var can_go_delay = 0.2#s
export(Color, RGBA) var ghost_modulate

var velocity_save = Vector2.ZERO

func move(delta):
	print("begindash")
	# Change hitbox + other animation things like sliding etc.
#	var anim = get_parent().get_parent().get_node("Sprite/AnimationTree3")
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunkdashing = true
	S.set_action(S.ActionType.DUNKDASH)
	P.gravity = Vector2.ZERO

	P.PlayerEffects.cloud_start()
	P.PlayerEffects.jump_start()
	P.PlayerEffects.ghost_start(0.18,0.04, ghost_modulate)
	P.PlayerEffects.distortion_start("fast_soft", 0.75)
	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)
	S.get_node("CanGoTimer").start(can_go_delay)

	velocity_save = S.velocity

#	var q = (S.dunkdash_basket.position+up_distance_to_basket*Vector2.UP) - P.position
#	q *= -P.dunkdash_speed/q.length()
#	q.y = max(q.y, P.jump_speed)
#	P.get_out(P.global_position, q)
	var q = (S.dunkdash_basket.position - P.position).normalized()
	q *= max(P.dunkdash_speed, velocity_save.dot(q))
	P.get_out(P.global_position, q)
	#print("Velocity: "+str(S.velocity))
	P.get_node("Camera").screen_shake(0.2,10)

func move_end():
	print("enddash")
	P.gravity = P.based_gravity
	if S.direction_p * S.move_direction < 0:
		S.velocity.x = 0.0
	else :
		S.velocity.x *= 0.5
	S.velocity.y *= 0.5
	#P.get_node("Sprite").modulate = Color.white
