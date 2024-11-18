extends State

@export var character_body : CharacterBody2D
@export var logic : StatusLogic
@export var animation_player : AnimationPlayer

@export var throw_speed : float = 400 ##pix/s

@export var idle_state : State
var end_passing : bool = false
## Called when entering this State.
## If there is an immediate transition, return the next State, otherwise return
## this state or null.
func enter(previous_state : State = null) -> State:
	end_passing = false
	animation_player.play("passing")
	print(character_body.name+" passing")
	return self

func passing():
	var direction = Global.get_current_player().global_position - character_body.global_position
	logic.set_flipper(direction.x)
	logic.throw_ball(character_body.global_position, throw_speed * direction.normalized()+150*Vector2.UP)
	end_passing = true

## Called by the parent StateMachine during the _physics_process call, after
## the StatusLogic physics_process call.
func physics_process(delta) -> State:
	if end_passing:
		return idle_state
	## CharacterBody physics_process()
	# Add the gravity.
	if not character_body.is_on_floor():
		character_body.velocity.y += Global.default_gravity.y * delta
	character_body.velocity.x = move_toward(character_body.velocity.x, 0, 100)
	character_body.move_and_slide()
	return self
