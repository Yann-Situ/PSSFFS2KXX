@icon("res://assets/art/icons/basketball-r-16.png")
extends Area2D
class_name BallHandler
# Ball pickup, thrower, shooter, selector, ballwaller

@export var P : Player
@export var ball_label : RichTextLabel
@export var ball_holder : BallHolder
@export var can_pick : bool = true : set = set_can_pick ## can_pick must be set by S, depending on action like is_shooting, or cinematics; it will modify ball_holder.pick_locked accordingly
#@onready var S = P.get_state_node()

var held_ball : Ball = null : get = get_held_ball ## will correspond to ball_holder.get_held_ball(0) or null
var selected_ball : Ball = null : get = get_selected_ball
var released_ball : Ball = null

const collision_mask_balls = 4
const released_ball_delay = 0.5

func _ready():
	assert(is_instance_valid(P))
	assert(is_instance_valid(ball_holder))

func has_ball() -> bool:
	return held_ball != null
func has_selected_ball() -> bool:
	return selected_ball != null
func has_ball_and_is_selected():
	return has_ball() and selected_ball == held_ball

func set_can_pick(b : bool) -> void:
	ball_holder.pick_locked = !b
	can_pick = b
	
func get_held_ball() -> Ball:
	if ball_holder.is_holding():
		held_ball = ball_holder.get_held_ball(0)
	else:
		held_ball = null
	return held_ball
	
func get_selected_ball() -> Ball:
	return selected_ball

func get_throw_position():
	# return the global position of the beginning of the throw, depending on the
	# position of the player and the flip value :
	return $ThrowPosition.global_position

####################################################################################################
## Ball holding system 
# The call are as follows:
# 	- the holder wants to pickup the ball and call ball.pick(holder)
# 	- pick(holder) check if the holder is able to pickup the ball.
# 		If yes, it returns true and update the current_holder and 
#		call holder._pick(ball), which will emit a signal
# 	- Then ball call holder._process_ball(ball, delta) and
# 		holder._physics_process_ball(ball, delta) each frames,
#		which will emit a signal each time
# 	- To get out, call ball.release() or ball.throw(pos,vel), it will call
# 		holder._release(ball), which will emit a signal

## pickup
func _on_Ball_Handler_body_entered(ball):
	#print(ball.name+" entering "+Player.name+" ballhandler area")
	if ball == released_ball:
			print_debug(" - "+ball.name+" is ignored because it was just released")
			return
	if not ball is Ball:
			print_debug(" - "+ball.name+" is ignored because it is not a Ball")
			return
	if ball.pick(ball_holder):
		ball.select(P) # will then deselect the current ball by calling P.deselect_ball which calls self.deselect_ball
		ball.global_position = P.global_position

func throw_ball(throw_global_position : Vector2, speed : Vector2) -> bool:
	if !has_ball():
		printerr("throw_ball but ball_handler.has_ball() is false")
		return false
	released_ball = held_ball
	var tween = get_tree().create_tween()
	tween.tween_interval(released_ball_delay)
	tween.tween_callback(self._set_released_ball_null)
	
	held_ball.get_node("Visuals").position = Vector2.ZERO
	held_ball.throw(throw_global_position, speed)
	return true
func _set_released_ball_null():
	released_ball = null

func shoot_ball(): # called by animation
	throw_ball(get_throw_position(), Vector2.ZERO)

## connected to ball_holder.processing_ball(ball, delta)
func set_has_ball_position(ball : Ball) -> void: # TODO it might be interesting to do it with a Remote2D node
	if ball != null:
		#ball.global_position = $HasBallPosition.global_position
		ball.get_node("Visuals").position = $HasBallPosition.global_position - P.global_position
		#held_ball.transform.origin = + $HasBallPosition.position

#func pickup_ball(ball : Ball):
	#print(P.name+" pickup "+ball.name)
	#if has_ball() and held_ball == ball:
		#push_warning(name+" pickup_ball on held_ball")
		#return
	#elif has_ball() :
		#push_warning(name+" pickup_ball but has_ball() is true")
		#return
	## has_ball() = true
	#held_ball = ball
	#
	#self.is_picking.emit(ball)
	#ball.pickup(P)
	#ball.select(P) # will then deselect the current ball by calling P.deselect_ball which calls self.deselect_ball

#func free_ball(ball : Ball): # set out  active_ball and has_ball
	## called by ball when thrown or deleted
	#if has_ball() and held_ball == ball:
		#held_ball = null
		#self.is_freeing.emit(ball)
		#print(P.name+" free_ball")
	#elif has_ball() :
		#printerr(P.name+" free_ball on other ball")
	#else :
		#printerr(P.name+" free_ball but doesn't have ball")

## return if the ball.throw() was called
#func throw_ball(throw_global_position : Vector2, speed : Vector2) -> bool:
	#if !has_ball():
		#printerr("throw_ball but ball_handler.has_ball() is false")
		#return false
	#if held_ball._is_reparenting:
		#printerr("throw_ball but held_ball._is_reparenting is true")
		#return false
	#print("throw_ball "+held_ball.name)
	#released_ball = held_ball
	#held_ball.get_node("Visuals").position = Vector2.ZERO
	#held_ball.throw(throw_global_position, speed) # will call free_ball
#
	#var tween = get_tree().create_tween()
	#tween.tween_interval(released_ball_delay)
	#tween.tween_callback(self._set_released_ball_null)
	## Ugly old alternative:
	## await get_tree().create_timer(released_ball_delay).timeout
	## released_ball = null
	#return true

################################### SELECTION #############################################

func select_ball(ball : Ball): # called by player.select_ball, which is called by ball.select(P)
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

func deselect_ball(ball : Ball): # called by player.deselect_ball, which is called by ball.deselect(P)
	assert(selected_ball != null)
	selected_ball = null

	#TEMPORARY CONTROL NODE
	if ball_label:
		ball_label.clear()

################################### BALL WALL #############################################

func _on_BallWallDetector_body_entered(body):
	collision_mask = 0

func _on_BallWallDetector_body_exited(body):
	if $BallWallDetector.get_overlapping_bodies().is_empty():
		collision_mask = collision_mask_balls
