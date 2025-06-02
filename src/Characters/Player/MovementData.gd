## MovementData:
# should store:
#	velocity
#
# 	acceleration alterable
# 	force alterable
# 	speed alterable
#
# 	mass ; invmass
#
#   ambient data
@icon("res://assets/art/icons/movement.png")
extends Resource
class_name MovementData

@export var mass : float = 1.0 : set = set_mass## kg
@export var ambient : AmbientData : set = set_ambient
## ambient is handling all the physical and movement data induced by the
## environment (for instance, max_speed, friction, base_accel, etc.).

var velocity : Vector2 = Vector2.ZERO ## pix/s
var invmass : float
var direction_pressed : Vector2 = Vector2.ZERO

var force_alterable = Alterable.new(Vector2.ZERO)
var speed_alterable = Alterable.new(Vector2.ZERO)
var accel_alterable = Alterable.new(Vector2.ZERO)
var speed_scale : float = 1.0

func set_mass(v : float):
	mass = v
	if v == 0.0:
		invmass = INF
	else:
		invmass = 1.0/mass

func set_ambient(_ambient : AmbientData):
	if ambient == _ambient:
		return
	ambient = _ambient
	# update base values for alterable:
	force_alterable.set_base_value(ambient.base_force)
	speed_alterable.set_base_value(ambient.base_speed)
	accel_alterable.set_base_value(ambient.base_accel)

func duplicate_with_ambient_scaler(scaler : AmbientDataScaler) -> MovementData:
	var m = MovementData.new()
	m.mass = self.mass
	m.ambient = scaler.apply(self.ambient)
	m.velocity = self.velocity
	m.direction_pressed = self.direction_pressed
	m.force_alterable = self.force_alterable
	m.speed_alterable = self.speed_alterable
	m.accel_alterable = self.accel_alterable
	m.speed_scale = self.speed_scale
	return m

func _to_string() -> String:
	var s = "{ "
	s+= "velocity: "+str(self.velocity)
	s+= "; mass: "+str(self.mass)
	s+= "; direction: "+str(self.direction_pressed)
	s+= "; ambient: "+str(self.ambient)
	return s+" }"
