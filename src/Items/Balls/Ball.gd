extends PhysicBody
class_name Ball, "res://assets/art/ball/ball_test.png"

var selected = false # if selected by mouse
var holder = null # if hold by player
onready var selector = $Selector

export (float) var dust_threshold = 400

export(Color, RGBA) var col1
export(Color, RGBA) var col2
export(Color, RGBA) var col3

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["ball_0"]
	add_to_group("balls")

#func _draw():
#	# draw collision normal
#	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)

###########################################################
func reset_position():
	if holder != null:
		throw(Vector2.ZERO,Vector2.ZERO)
	position = start_position
	
func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	if (linear_velocity-collider_velocity).length() > dust_threshold:
		$Effects/DustParticle.restart()
	return true

func pickup(holder_node):
	if not holder_node.is_in_group("holders"):
		print("error["+name+"], holder_node is not in group `holders`.")
	if holder != null:
		holder.free_ball(self)
	self.disable_physics()
	holder = holder_node
	self.z_index = holder_node.z_index+1
	on_pickup(holder_node)

func throw(posi, velo):
	#$TrailHandler.set_node_to_trail(self)
	#$TrailHandler.start(2.0,0.1)
	self.enable_physics()
	position = posi
	linear_velocity = velo
	if holder != null:
		holder.free_ball(self)
	var previous_holder = holder
	holder = null
	self.z_index = Global.z_indices["ball_0"]
	on_throw(previous_holder)

func destruction(delay : float = 0.0):
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	$Animation.play("destruction") # will call queue_free
	throw(position, Vector2.ZERO)
	self.disable_physics()
	$Selector.toggle_selection(false)
	
################################################################################

func on_pickup(holder_node : Node):
	pass

func on_throw(previous_holder : Node):
	pass

func on_dunk():
	$Animation.play("dunk")

func on_goal():
	pass
	
func on_destruction():
	pass

################################################################################

func power_p(player,delta):
	if holder == null :
		add_force("attract", player.attract_force*(player.position - position).normalized())

func power_jp(player,delta):
	pass

func power_jr(player,delta):
	if holder == null :
		remove_force("attract")

