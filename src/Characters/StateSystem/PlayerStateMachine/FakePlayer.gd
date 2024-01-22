extends CharacterBody2D
class_name FakePlayer

@export var movement : MovementData
@export var physics_enabled : bool = true
var flip_h : bool = false

func _ready():
	pass

func _process(delta):
	$LabelState.text = $StateMachine.current_state.name
	$LabelVelocity.text = str(movement.velocity)
