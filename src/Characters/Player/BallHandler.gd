@icon("res://assets/art/icons/basketball-r-16.png")
extends Area2D
class_name BallHandler
# Ball pickup, thrower, shooter, selector, ballwaller
## TODO: rework to put the ball in this class

@export var P: NewPlayer
@export var ball_label: RichTextLabel
@export var can_pick: bool = true ## can_pick must be set by S, depending on has_ball and actions like is_shooting
#@onready var S = P.get_state_node()

var held_ball : Ball = null
var selected_ball : Ball = null
var released_ball : Ball = null

const collision_mask_balls = 4
const released_ball_delay = 0.3

func _ready():
	assert(is_instance_valid(P))

func has_ball() -> bool:
	return held_ball != null and held_ball is Ball
func has_selected_ball() -> bool:
	return selected_ball != null and selected_ball is Ball

func _on_Ball_Handler_body_entered(body):
	#print(body.name+" entering "+Player.name+" ballhandler area")
	if not can_pick:
		return
	if body.is_in_group("balls"):
		if body.is_reparenting():
			print_debug(" - ballhandler "+body.name+" is ignored because reparenting")
			return # Workaround because of https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/
		if body == released_ball:
			#released_ball = null
			print_debug(" - but "+body.name+" is ignored because it was just released")
			return
		# if has_ball() or S.is_shooting :
		# 	return
		# else :
		pickup_ball(body)

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	return $ThrowPosition.global_position

func set_has_ball_position(): # TODO it might be interesting to do it with a Remote2D node
	if held_ball != null:
		var sprite = held_ball.get_node("Visuals")
		sprite.position = $HasBallPosition.global_position - P.global_position # maybe should be optimize TODO
		#held_ball.transform.origin = + $HasBallPosition.position

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
	if has_ball() and held_ball == ball:
		push_warning(name+" pickup_ball on held_ball")
		return
	elif has_ball() :
		throw_ball(P.global_position, Vector2.ZERO)
	# has_ball() = true
	held_ball = ball
	if P.physics_enabled:
		P.set_collision_mask_value(10, true) #ball_wall collision layer
	P.collision_mask_save |= 1<<10 # same as set_collision_mask_value(10,true)
	ball.pickup(P)
	ball.select(P)

func free_ball(ball : Ball): # set out  active_ball and has_ball
	# called by ball when thrown or deleted
	if has_ball() and held_ball == ball:
		held_ball = null
		# has_ball() = false
		if P.physics_enabled:
			P.set_collision_mask_value(10, false) #ball_wall collision layer
		P.collision_mask_save &= ~(1<<10) # same as set_collision_mask_value(10, false)

		#print(str(P.collision_layer)+" "+str(P.collision_layer_save))
		print(P.name+" free_ball")
	elif has_ball() :
		printerr(P.name+" free_ball on other ball")
	else :
		printerr(P.name+" free_ball but doesn't have ball")


func throw_ball(throw_global_position : Vector2, speed : Vector2):
	if has_ball():
		print("throw "+held_ball.name)
		released_ball = held_ball
		held_ball.get_node("Visuals").position = Vector2.ZERO
		held_ball.throw(throw_global_position, speed) # will call free_ball

		var tween = get_tree().create_tween()
		tween.tween_interval(released_ball_delay)
		tween.tween_callback(self._set_released_ball_null)
		# Ugly old alternative:
		# await get_tree().create_timer(released_ball_delay).timeout
		# released_ball = null
func _set_released_ball_null():
	released_ball = null

func shoot_ball(): # called by animation
	throw_ball(get_throw_position(), P.ShootPredictor.shoot_vector_save)

####################################################################################################

func select_ball(ball : Ball): # called by ball.select(P)
	if selected_ball != null and selected_ball != ball:
			selected_ball.deselect(P)
	selected_ball = ball

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
	assert(selected_ball != null)
	if P.S.power_p: # Ugly to look for P.S.power_p TODO
		selected_ball.power_jr(P,0.0)
	selected_ball = null

	#TEMPORARY CONTROL NODE
	if ball_label:
		ball_label.clear()

####################################################################################################

func _process(delta):#TODO use set_process in pickup ?
	if has_ball() :
		set_has_ball_position()

func _on_BallWallDetector_body_entered(body):
	collision_mask = 0

func _on_BallWallDetector_body_exited(body):
	if $BallWallDetector.get_overlapping_bodies().is_empty():
		collision_mask = collision_mask_balls
