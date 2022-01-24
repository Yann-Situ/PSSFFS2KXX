extends Action

export var up_distance_to_basket = 32#px
export(Color, RGBA) var ghost_modulate

func move(delta):
	# Change hitbox + other animation things like sliding etc.
#	var anim = get_parent().get_parent().get_node("Sprite/AnimationTree3")
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunkdashing = true
	S.set_action(S.ActionType.DUNKDASH)
	P.PlayerEffects.dust_start()
	P.PlayerEffects.jump_start()
	P.PlayerEffects.ghost_start(0.35,0.07, ghost_modulate)
	S.get_node("ToleranceDunkJumpPressTimer").stop()
	S.get_node("CanJumpTimer").start(S.jump_countdown)

	var q = (S.dunkjump_basket.position+up_distance_to_basket*Vector2.UP) - P.position
	P.get_out(P.global_position, -P.dunk_speed * q.normalized())
	#print("Velocity: "+str(S.velocity))
	P.get_node("Camera").screen_shake(0.2,10)

