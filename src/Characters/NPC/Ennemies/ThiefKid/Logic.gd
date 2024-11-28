extends StatusLogic

@export var fetcher : Area2D
@export var picker : Area2D
@export var positioner : RemoteTransform2D
@export var flipper : Marker2D
@export var holder : BallHolder

var just_released_ball : bool = false ## if the enity juste released a ball. reset to true with a timer
@export var can_go : bool = false ## if the character can go toward the ball set by animation (walk and exclamation)

var fetch_ball : Ball = null
var held_ball : Ball = null : get = get_held_ball ## will correspond to holder.get_held_ball(0) or null

func _ready():
	add_to_group("holders")
	assert(is_instance_valid(fetcher))
	assert(is_instance_valid(picker))
	assert(is_instance_valid(positioner))
	assert(is_instance_valid(flipper))
	assert(is_instance_valid(holder))

func get_held_ball() -> Ball:
	if holder.is_holding():
		held_ball = holder.get_held_ball(0)
	else:
		held_ball = null
	return held_ball

func _on_ball_fetcher_body_entered(body):
	# priority on old balls
	if body is Ball and not found_ball():
		fetch_ball = body

func _on_ball_fetcher_body_exited(body):
	if not body is Ball:
		return
	if fetch_ball == body:
		fetch_ball = null
	if fetch_ball == null:
		var bodies = fetcher.get_overlapping_bodies()
		if not bodies.is_empty():
			fetch_ball = bodies[0]
			print("fetch_ball: "+fetch_ball.name)

func _on_ball_picker_body_entered(body):
	if not just_released_ball and body is Ball:
		if body.pick(holder):
			positioner.remote_path = body.get_path() 

func throw_ball(throw_global_position : Vector2, speed : Vector2) -> bool:
	if !has_ball():
		printerr("throw_ball but ball_handler.has_ball() is false")
		return false
	held_ball.throw(throw_global_position, speed)
	positioner.remote_path = NodePath("")
	just_released_ball = true
	$ReleasedBallTimer.start() # will reset can_pick to true
	return true

func _on_released_ball_timer_timeout():
	just_released_ball = false
	var bodies = picker.get_overlapping_bodies()
	for body in bodies:
		_on_ball_picker_body_entered(body)

func found_ball() -> bool:
	return fetch_ball != null
	
func has_ball() -> bool:
	return held_ball != null
	
func set_flipper(b):
	if b<0:
		flipper.scale.x = -1.0
	elif b>0:
		flipper.scale.x = 1.0

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
