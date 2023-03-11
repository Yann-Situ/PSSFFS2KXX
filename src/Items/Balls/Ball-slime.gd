extends Ball

@export (float) var stuck_force = 900
var stuck = false

func _ready():
	self.mass = 1.4
	self.set_friction(1.0)
	self.set_bounce(0.0)

func update_linear_velocity(delta):
	if not stuck or (Vector2(0.0,gravity*mass)+applied_force).length()>stuck_force :
		linear_velocity.y += gravity * delta
		linear_velocity += invmass * applied_force * delta
		stuck = false
	else :
		linear_velocity = Vector2(0.0,0.0)

func collision_effect(collision):
	linear_velocity = Vector2(0.0,0.0)
	stuck = true
	return false

func enable_physics():
	physics_enabled = true
	stuck = false


func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	stuck = false
	
func power_jr(player,delta):
	pass
