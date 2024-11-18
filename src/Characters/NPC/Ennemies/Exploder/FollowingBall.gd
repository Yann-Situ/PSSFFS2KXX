extends State

@export var entity : Node2D
@export var logic : StatusLogic
@export var animation_player : AnimationPlayer
@export var speed : float = 100 ##pix/s
@export var radius_explodes : float = 10## radius from which the explode state triggers

@export var fetching_state : State
@export var explodes_state : State

## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	animation_player.play("following")
	return self

## Called just before entering the next State. Should not contain await or time
## stopping functions
func exit() -> void:
	pass

## Called by the parent StateMachine during the _process call, after
## the StatusLogic process call.
func process(delta) -> State:
	return self

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	if not logic.found_ball():
		return fetching_state
	var q = logic.ball.global_position - entity.global_position
	var l = q.length()
	if l < radius_explodes:
		return explodes_state
	var vel = min(speed, q.length())
	entity.global_position += vel*delta * q.normalized()
	return self
