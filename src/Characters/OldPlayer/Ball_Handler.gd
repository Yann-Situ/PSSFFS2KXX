extends Area2D
# Ball pickup, thrower, shooter, selector, ballwaller
## TODO: rework to put the ball in this class

@export var P: OldPlayer
@export var ball_label: RichTextLabel
@onready var S = P.get_state_node()

const collision_mask_balls = 4
const released_ball_delay = 0.3

func _ready():
	assert(is_instance_valid(P))

func _on_Ball_Handler_body_entered(body):
	if body.is_in_group("balls"):
		if body.is_reparenting():
			print_debug(" - ballhandler "+body.name+" is ignored because reparenting")
			return # Workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
		if body == S.released_ball:
			#S.released_ball = null
			print_debug(" - but "+body.name+" is ignored because it was just released")
			return
		if S.has_ball or S.is_shooting :
			return
		else :
			pickup_ball(body)

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	return $ThrowPosition.global_position

func set_has_ball_position():
	var sprite = S.active_ball.get_node("Visuals")
	sprite.position = $HasBallPosition.global_position - P.global_position # maybe should be optimize TODO
	#S.active_ball.transform.origin = + $HasBallPosition.position

####################################################################################################

# Ball Holder call order:
# Pickup:
#- holder.pickup_ball(ball)
#	- ball.pickup(holder)
#		- old_holder.free_ball(ball) # if the old_holder was not the current room
#		- reparenting system
#		- ball.disable_physics()
#		- ball.on_pickup(holder) # additional effect
# Throw:
#- old_holder.throw_ball(...) # or any function that calls ball.throw(...)
#	- ball.throw(position, velocity)
#		- ball.enable_physics()
#		- old_holder.free_ball(ball)
#		- reparenting system
#		- ball.on_throw(old_holder) # additional effect

func pickup_ball(ball : Ball):
	print(P.name+" pickup "+ball.name)
	S.has_ball = true
	S.active_ball = ball
	if P.physics_enabled:
		P.set_collision_mask_value(10, true) #ball_wall collision layer
	P.collision_mask_save |= 1<<10 # same as set_collision_mask_value(10,true)
	ball.pickup(P)
	ball.select(P)

func free_ball(ball : Ball): # set out  active_ball and has_ball
	# called by ball when thrown or deleted
	if S.has_ball and S.active_ball == ball:
		S.active_ball = null
		S.has_ball = false
		if P.physics_enabled:
			P.set_collision_mask_value(10, false) #ball_wall collision layer
		P.collision_mask_save &= ~(1<<10) # same as set_collision_mask_value(10, false)

		#print(str(P.collision_layer)+" "+str(P.collision_layer_save))
		print(P.name+" free_ball")
	elif S.has_ball :
		printerr(P.name+" free_ball on other ball")
	else :
		printerr(P.name+" free_ball but doesn't have ball")


func throw_ball(throw_global_position, speed):
	if S.has_ball and S.active_ball != null :
		print("throw "+S.active_ball.name)
		S.released_ball = S.active_ball
		S.active_ball.get_node("Visuals").position = Vector2.ZERO
		S.active_ball.throw(throw_global_position, speed) # will call free_ball
		# WARNING: Ugly but it works :
		await get_tree().create_timer(released_ball_delay).timeout
		S.released_ball = null

func shoot_ball(): # called by animation
	throw_ball(get_throw_position(), P.ShootPredictor.shoot_vector_save)

####################################################################################################

func select_ball(ball : Ball): # called by ball.select(P)
	if S.selected_ball != null and S.selected_ball != ball:
			S.selected_ball.deselect(P)
	S.selected_ball = ball

	#TEMPORARY CONTROL NODE
	if ball_label:
		ball_label.clear()
		ball_label.add_text(ball.name)
		# ball_label.newline()
		# ball_label.add_text("Ball mass  : "+str(ball.mass))
		# ball_label.newline()
		# ball_label.add_text("Ball frict : "+str(ball.friction))
		# ball_label.newline()
		# ball_label.add_text("Ball bounc : "+str(ball.bounce))
		# ball_label.newline()
		# ball_label.add_text("Ball posit : "+str(ball.position - P.position))

func deselect_ball(ball : Ball): # called by ball.deselect(P)
	assert(S.selected_ball != null)
	if S.power_p:
		S.selected_ball.power_jr(P,0.0)
	S.selected_ball = null

	#TEMPORARY CONTROL NODE
	if ball_label:
		ball_label.clear()

####################################################################################################

func _physics_process(delta):#TODO use set_physics_process in pickup ?
	if S.has_ball and S.active_ball != null :
		set_has_ball_position()

func _on_BallWallDetector_body_entered(body):
	collision_mask = 0

func _on_BallWallDetector_body_exited(body):
	if $BallWallDetector.get_overlapping_bodies().is_empty():
		collision_mask = collision_mask_balls
