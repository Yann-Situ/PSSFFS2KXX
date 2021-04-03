extends PhysicBody
class_name KinematicBall, "res://assets/art/ball/ball_test.png"

var applied_force = Vector2(0.0,0.0) setget set_applied_force
onready var invmass = 1/mass
onready var selector = $Selector

export (float) var dust_threshold = 400

func _ready():
	pass

func _physics_process(delta):
	if not physics_enabled:
		return
	linear_velocity.y += gravity * delta
	linear_velocity += invmass * applied_force * delta
	var collision = move_and_collide(linear_velocity * delta, false)
	if collision:
		collision_effect(collision)
		if collision.collider is PhysicBody :
			var m2 = collision.collider.mass
			var summass = m2 + mass
			linear_velocity = 1/summass*((mass-m2) * linear_velocity + 2*m2 * collision.collider_velocity)
			move_and_collide(collision.remainder.bounce(collision.normal))#may cause pb on corners ?
		else:
			var n = collision.normal
			var t = n.tangent()
			var bounce_linear_velocity = bounce*linear_velocity.bounce(n)
			var vel_n = n.dot(bounce_linear_velocity)
			var vel_t
			var motion
			if vel_n < 2*gravity*delta:
				#TODO seuil à déterminer
				#sliding
				vel_t = lerp(t.dot(linear_velocity), 0, friction)
				linear_velocity = vel_t*t
				motion = collision.remainder.dot(t)*t
			else :
				#bouncing
				vel_t = lerp(t.dot(bounce_linear_velocity), 0, friction)
				linear_velocity = vel_n*n + vel_t*t
				motion = collision.remainder.bounce(n)
			move_and_collide(motion)#may cause pb on corners ?

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
