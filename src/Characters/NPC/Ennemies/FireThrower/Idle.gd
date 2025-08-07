extends State

@export var character_body : CharacterBody2D
@export var fire_thrower : Node
@export var animation_player : AnimationPlayer

@export var passing_state : State

## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	animation_player.play("idle")
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
	var direction = Global.get_current_player().global_position - character_body.global_position
	if fire_thrower.player_is_detected():
		fire_thrower.set_flipper(direction.x)
		if fire_thrower.has_ball():
			return passing_state
		if fire_thrower.spawning_timer.is_stopped():
			fire_thrower.spawn_balls()
	
	## CharacterBody physics_process()
	# Add the gravity.
	if not character_body.is_on_floor():
		character_body.velocity.y += Global.default_gravity.y * delta
	character_body.velocity.x = move_toward(character_body.velocity.x, 0, 100)
	
	character_body.move_and_slide()
	
	return self
