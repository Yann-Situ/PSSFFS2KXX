extends State

@export var character_body : CharacterBody2D
@export var logic : StatusLogic
@export var animation_player : AnimationPlayer

@export var following_state : State
@export var passing_state : State

## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	animation_player.queue("idle")
	print(character_body.name+" idle")
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
	if logic.found_ball():
		animation_player.play("exclamation")
		return following_state
	
	## CharacterBody physics_process()
	# Add the gravity.
	if not character_body.is_on_floor():
		character_body.velocity.y += Global.default_gravity.y * delta
	character_body.velocity.x = move_toward(character_body.velocity.x, 0, 100)
	
	var direction = Global.get_current_player().global_position - character_body.global_position
	logic.set_flipper(direction.x)
	
	character_body.move_and_slide()
	
	return self
