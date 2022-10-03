extends Action

export var slide_duration = 0.80

func move(delta):
	# TODO
	# Change hitbox + other animation things like sliding etc.
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_crouching = true

	S.is_sliding = true
	var target_friction = 0.2#P.floor_friction
	var tween = get_tree().create_tween()
	tween.tween_property(P, "floor_friction", target_friction, slide_duration).from(0.0).set_ease(Tween.EASE_IN)
	tween.tween_callback(self, "move_end")
	P.PlayerEffects.dust_start()
	
func move_end():
	S.is_sliding = false
