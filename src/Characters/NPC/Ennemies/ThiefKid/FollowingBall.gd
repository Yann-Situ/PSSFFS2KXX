extends State

@export var character_body : CharacterBody2D
@export var logic : StatusLogic
@export var animation_player : AnimationPlayer

@export var walk_speed : float = 100 ##pix/s

@export var idle_state : State
@export var passing_state : State

## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	animation_player.queue("walk")
	print(character_body.name+" following")
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
	if logic.has_ball():
		# character picked up a ball
		return passing_state
	if not logic.found_ball():
		animation_player.play("interrogation")
		return idle_state
	
	## CharacterBody physics_process()
	# Add the gravity.
	if not character_body.is_on_floor():
		character_body.velocity.y += Global.default_gravity.y * delta
	var q = logic.fetch_ball.global_position - character_body.global_position
	if logic.can_go:
		character_body.velocity.x = sign(q.x)*walk_speed
	else:
		character_body.velocity.x = move_toward(character_body.velocity.x, 0, 100)
		
	logic.set_flipper(q.x)
	character_body.move_and_slide()

	return self
