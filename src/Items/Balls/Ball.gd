extends PhysicBody
class_name Ball, "res://assets/art/ball/ball_test.png"

var selected = false # if selected by mouse
var holder = null # if hold by player
onready var selector = $Selector
#var normal_colision = Vector2(0.0,0.0)
#var color1 = Color(1.0,0.2,0.3)
#var color2 = Color(1.0,0.8,0.0)
#var color3 = Color(0.4,1.0,0.2)
#var color_colision = color1

export (float) var dust_threshold = 400

func _ready():
	self.z_as_relative = false
	self.z_index = Global.z_indices["ball_0"]
	add_to_group("balls")

#func _draw():
#	# draw collision normal
#	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)

###########################################################

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	if (linear_velocity-collider_velocity).length() > dust_threshold:
		$DustParticle.restart()
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

################################################################################

func on_pickup(holder_node : Node):
	pass

func on_throw(previous_holder : Node):
	pass

func power_p(player,delta):
	if holder == null :
		add_force("attract", player.attract_force*(player.position - position).normalized())

func power_jp(player,delta):
	pass

func power_jr(player,delta):
	if holder == null :
		remove_force("attract")
