extends PhysicBody
class_name Ball, "res://assets/art/ball/ball_test.png"

var selected = false # if selected by mouse
var active = false # if hold by player
onready var selector = $Selector
#var normal_colision = Vector2(0.0,0.0)
#var color1 = Color(1.0,0.2,0.3)
#var color2 = Color(1.0,0.8,0.0)
#var color3 = Color(0.4,1.0,0.2)
#var color_colision = color1

export (float) var dust_threshold = 400

func _ready():
	add_to_group("balls")

#func _draw():
#	# draw collision normal
#	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)

###########################################################

func collision_effect(collision):
	if linear_velocity.length() > dust_threshold:
		$DustParticle.restart()
	return true

func pickup():
	self.disable_physics()
	active = true

func throw(posi, velo):
	#$TrailHandler.set_node_to_trail(self)
	#$TrailHandler.start(2.0,0.1)
	self.enable_physics()
	position = posi
	linear_velocity = velo
	active = false

################################################################################

func power_p(player,delta):
	set_applied_force(player.attract_force*(player.position - position).normalized())

func power_jp(player,delta):
	pass

func power_jr(player,delta):
	set_applied_force(Vector2(0.0,0.0))