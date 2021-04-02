extends KinematicBody2D
class_name PhysicBody

export (bool) var physics_enabled = true
onready var start_position = global_position
var should_reset = false

#physics :
var velocity = Vector2(0.0,0.0)
export (float) var gravity_coeff = 1.0
var gravity = gravity_coeff*ProjectSettings.get_setting("physics/2d/default_gravity") # pix/s²
export (float) var mass = 1.0
export (float) var friction = 0.15 setget set_friction
export (float) var bounce = 0.5 setget set_bounce
func set_friction(new_value):
	friction = new_value
func set_bounce(new_value):
	bounce = new_value

func _ready():
	Global.list_of_physical_nodes.append(self)
	if !Global.playing :
		disable_physics()

func disable_physics():
	physics_enabled = false
	velocity *= 0

func enable_physics():
	physics_enabled = true

func reset_position():
	position = start_position

# Should be in any items that can be picked/placed
func set_start_position(posi):
	start_position = posi
	global_position = posi
