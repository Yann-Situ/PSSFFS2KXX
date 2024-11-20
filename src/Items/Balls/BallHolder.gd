@icon("res://assets/art/icons/round-r-16.png")
extends Node2D
class_name BallHolder
## handle how a ball can belong to another node
# The call are as follows:
# 	- the holder wants to pickup the ball and call ball.pick(holder)
# 	- pick(holder) check if the holder is able to pickup the ball.
# 		If yes, it returns true and update the current_holder and 
#		call holder._pick(ball), which will emit a signal
# 	- Then ball calls holder._process_ball(ball, delta) and
# 		holder._physics_process_ball(ball, delta) each frames,
#		which will emit a signal each time
# 	- To get out, call ball.release(), it will call
# 		holder._release(ball), which will emit a signal

signal processing_ball(ball : Ball, delta : float)
signal physics_processing_ball(ball : Ball, delta : float)
signal picking(ball : Ball)
signal releasing(ball : Ball)

@export var holder_priority : int = 0 : get = get_holder_priority ## priority between holders
@export var max_ball : int = 1 ## maximal number of balls simultaneously held
@export var pick_locked : bool = false ## If true, cannot pick a new ball
var held_balls : Array[Ball] = [] ## it could be a dictionary but in practice 
# there are only few held_balls on board

func can_hold() -> bool:
	return (not pick_locked) and (held_balls.size() < max_ball) 

func get_holder_priority()-> int:
	return holder_priority

## if null or no arguments, then return true iff it's not holding any ball
## else, return if ball is in held_balls
func is_holding(ball : Ball = null) -> bool:
	if ball == null:
		return held_balls != []
	return ball in held_balls

## return the i-th ball, or error if no balls
func get_held_ball(i : int) -> Ball:
	if i < 0 or i >= held_balls.size():
		push_error(name+"get_held_ball out of bound")
		return null
	return held_balls[i]

func _process_ball(ball : Ball, delta : float) -> void:
	processing_ball.emit(ball, delta)
func _physics_process_ball(ball : Ball, delta : float) -> void:
	physics_processing_ball.emit(ball, delta)

## note that checking if the ball can be picked is done by ball.pick() (calling actually ball_holder.can_hold())
func _pick(ball : Ball) -> void:
	if is_holding(ball):
		printerr("ball already in held_balls")
		return
	held_balls.append(ball)
	picking.emit(ball)
	
func _release(ball : Ball) -> void:
	if !is_holding(ball):
		printerr("ball not in held_balls")
		return
	held_balls.erase(ball)
	releasing.emit(ball)
