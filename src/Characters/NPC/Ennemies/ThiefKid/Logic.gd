extends StatusLogic

@export var fetcher : Area2D
@export var picker : Area2D
@export var positioner : RemoteTransform2D
@export var flipper : Marker2D

var just_released_ball : bool = false ## if the enity juste released a ball. reset to true with a timer
@export var can_go : bool = false ## if the character can go toward the ball set by animation (walk and exclamation)

var fetch_ball : Ball = null
var held_ball : Ball = null

func _ready():
	add_to_group("holders")

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
		pickup_ball(body)

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

# Ball Holder call order:
# Pickup:
#- holder.pickup_ball(ball)
# - is_picking.emit
#	- ball.pickup(holder)
#		- old_holder.free_ball(ball) # if the old_holder was not the current room
#				- old_holder.is_freeing.emit
#		- reparenting system
#		- ball.disable_physics()
#		- ball.on_pickup(holder) # additional effect
# Throw:
#- old_holder.throw_ball(...) # or any function that calls ball.throw(...)
#	- ball.throw(position, velocity)
#		- old_holder.free_ball(ball)
#				- old_holder.is_freeing.emit
#		- reparenting system
#		- ball.enable_physics()
#		- ball.on_throw(old_holder) # additional effect

func pickup_ball(ball : Ball):
	print(self.name+" pickup "+ball.name)
	if has_ball() and held_ball == ball:
		push_warning(name+" pickup_ball on held_ball")
		return
	elif has_ball() :
		push_warning(self.name+" pickup_ball but has_ball() is true")
		return
	# has_ball() = true
	held_ball = ball
	ball.pickup(self)
	# positioner.remote_path = held_ball.get_path() # ERROR: E 0:00:33:0626   Logic.gd:84 @ pickup_ball(): Cannot get path of node as it is not in a scene tree.

func free_ball(ball : Ball):
	# called by ball when thrown or deleted
	if has_ball() and held_ball == ball:
		held_ball = null
		#positioner.remote_path = NodePath("") # ERROR: E 0:00:33:0626   Logic.gd:84 @ pickup_ball(): Cannot get path of node as it is not in a scene tree.
		print(self.name+" free_ball")
		just_released_ball = true
		$ReleasedBallTimer.start() # will reset can_pick to true
	elif has_ball() :
		printerr(self.name+" free_ball on other ball")
	else :
		printerr(self.name+" free_ball but doesn't have ball")

## return if the ball.throw() was called
func throw_ball(throw_global_position : Vector2, speed : Vector2) -> bool:
	if !has_ball():
		printerr("throw_ball but ball_handler.has_ball() is false")
		return false
	if held_ball._is_reparenting:
		printerr("throw_ball but held_ball._is_reparenting is true")
		return false
	print("throw_ball "+held_ball.name)
	held_ball.get_node("Visuals").position = Vector2.ZERO
	held_ball.throw(throw_global_position, speed) # will call free_ball
	return true
