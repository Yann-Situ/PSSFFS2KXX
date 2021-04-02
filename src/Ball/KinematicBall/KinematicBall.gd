extends KinematicBody2D
class_name KinematicBall, "res://assets/art/ball/ball.png"

# Classical ball
export (bool) var physics_enabled = true
export (bool) var selected = false
export (Color) var selection_color = Color(1.0,1.0,1.0) #setget set_selection_color
var selection_color_mid = Color(selection_color.r*0.5, selection_color.g*0.5, selection_color.b*0.5)

onready var collision = $collision
onready var start_position = global_position
var should_reset = false
var temporary_position = Vector2(0,0)
var temporary_velocity = Vector2(0,0)

#physics :
export (float) var friction = 0.15 setget set_friction
export (float) var bounce = 0.15 setget set_bounce
func set_friction(new_value):
	friction = new_value
func set_bounce(new_value):
	bounce = new_value
	
func _ready():
	self.mass = 1.0
	self.set_friction(0.15)
	self.set_bounce(0.5)
	Global.list_of_physical_nodes.append(self)
	if !Global.playing :
		disable_physics()

############################################
# The three following functions should be in any physical item that can be picked/placed.

func disable_physics():
	physics_enabled = false
	collision.disabled = true
	#Just In Case
	linear_velocity *= 0
	angular_velocity *= 0


func enable_physics():
	physics_enabled = true
	collision.disabled = false

func reset_position():
	throw(start_position, Vector2(0.0,0.0))

# Should be in any items that can be picked/placed
func set_start_position(posi):
	start_position = posi
	global_position = posi

###########################################################

func throw(posi, velo):
	should_reset = true
	temporary_position = posi
	temporary_velocity = velo

func _integrate_forces(state):
	if should_reset :
		should_reset = false
		state.transform.origin = temporary_position
		state.linear_velocity = temporary_velocity
	# if state.linear_velocity.length() > 400:
	# 	var d = min(state.linear_velocity.length()/400 - 1, 0.2)
	# 	$Sprite.scale = (Vector2(1+d,1-d))
	# 	$Sprite.rotation = (state.linear_velocity.angle())
	# else :
	# 	$Sprite.scale = (Vector2(1,1))
	# 	$Sprite.rotation = (0)
	integrate_forces_child(state)

func integrate_forces_child(state):
	pass

#########################################################################

func set_selection_color(col):
	$Sprite_Selection.modulate = col

func toggle_selection(b):
	selected = b
	if selected :
		set_selection_color(selection_color)
		$Sprite_Selection.visible = true
	else :
		$Sprite_Selection.visible = false
	
func _on_Ball_mouse_entered():
	if !selected:
		set_selection_color(selection_color_mid)
		$Sprite_Selection.visible = true
	Global.mouse_ball = self

func _on_Ball_mouse_exited():
	if !selected:
		$Sprite_Selection.visible = false
	if Global.mouse_ball == self:
		Global.mouse_ball = null
