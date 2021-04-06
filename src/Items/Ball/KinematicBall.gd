extends PhysicBody
class_name KinematicBall, "res://assets/art/ball/ball_test.png"

var applied_force = Vector2(0.0,0.0) setget set_applied_force
onready var invmass = 1/mass
onready var selector = $Selector
var normal_colision = Vector2(0.0,0.0)
export var color1 = Color(1.0,0.2,0.3)
export var color2 = Color(1.0,0.8,0.0)
export var color3 = Color(0.4,1.0,0.2)
var color_colision = color1

export (float) var dust_threshold = 400

func _ready():
	pass

func _draw():
	draw_line(Vector2(0.0,0.0), Vector2(0.0,0.0)+50.0*normal_colision, color_colision)
			
func _physics_process(delta):
	if not physics_enabled:
		return
	linear_velocity.y += gravity * delta
	linear_velocity += invmass * applied_force * delta
	var collision = move_and_collide(linear_velocity * delta, false)
	if collision:
		collision_effect(collision)
		var n = collision.normal
		var t = n.tangent()
		normal_colision = n
		if collision.collider is PhysicBody :
			color_colision = color3
			var m2 = collision.collider.mass
			var summass = m2 + mass
			linear_velocity = 1/summass*((mass-m2) * linear_velocity + 2*m2 * collision.collider_velocity)
			#collision.collider.set_linear_velocity(1/summass*(2*mass * linear_velocity + (m2-mass) * collision.collider_velocity))
			#collision.collider.apply_impulse(m2/summass*(2*mass * linear_velocity + (m2-mass) * collision.collider_velocity))
			move_and_collide(collision.remainder.bounce(collision.normal),false)#may cause pb on corners ?
		else:
			var bounce_linear_velocity = bounce*linear_velocity.bounce(n)
			var vel_n = n.dot(bounce_linear_velocity)
			var vel_t
			var motion
			if vel_n < 2.5*gravity*delta:
				#TODO seuil à déterminer
				#sliding
				color_colision = color1
				vel_t = lerp(t.dot(linear_velocity), 0, friction)
				linear_velocity = vel_t*t
				motion = collision.remainder.dot(t)*t
				move_and_collide(motion,false)
				#linear_velocity = move_and_slide(linear_velocity,n,false,4,0.79,false)
			else :
				#bouncing
				color_colision = color2
				vel_t = lerp(t.dot(bounce_linear_velocity), 0, friction)
				linear_velocity = vel_n*n + vel_t*t
				motion = collision.remainder.bounce(n)
				move_and_collide(motion,false)#may cause pb on corners ?
	else :
		normal_colision = Vector2(0.0,0.0)
	update()

###########################################################

func collision_effect(collision):
	if linear_velocity.length() > dust_threshold:
		$DustParticle.restart()

func throw(posi, velo):
	position = posi
	linear_velocity = velo

func set_applied_force(force):
	applied_force=force

func apply_impulse(impulse):
	linear_velocity += invmass * impulse

func add_force(force):
	applied_force += force
