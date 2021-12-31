extends Action

var pos_tween

func _ready():
	pos_tween = Tween.new()
	pos_tween.name = "PosTween"
	add_child(pos_tween)
	
func move(delta):
	# Change hitbox + other animation things like sliding etc.
	
	# at this point, can_dunk is true so S.dunk_basket is not null
	S.is_aiming = false # cancel aiming for the moment
	S.aim_direction = 0
	P.ShootPredictor.clear()
	S.is_dunking = true
	S.is_dunkjumping = false
	S.velocity.x = 0
	S.velocity.y = 0
	
	S.get_node("CanDunkTimer").start(S.dunk_countdown)
	#S.get_node("CanGoTimer").start(0.32)
	pos_tween.follow_property(P, "global_position", P.global_position, \
		S.dunk_basket, "dunk_global_position", \
		0.32, Tween.TRANS_LINEAR)
	pos_tween.start()
	
	yield(get_tree().create_timer(0.32), "timeout")
	
	# at this point, S.dunk_basket can be null
	P.get_node("Camera").screen_shake(0.3,30)
	S.dunk_basket.dunk() # be careful, selected basket is sometimes null because the player got out of the zone...
