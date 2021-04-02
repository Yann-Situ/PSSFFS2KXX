extends "res://src/Ball/Ball.gd"
export (float) var boum_min = 100
export (float) var boum_max = 1000
export (float) var distance_max = 48
export (float) var speed_threshold = 150


# Heavy ball, with no bouncing and large mass
func _ready():
	$Sprite.texture = preload("res://assets/art/ball/ball_boum.png")
	self.mass = 1.0
	self.set_friction(0.15)
	self.set_bounce(0.3)

func boum():
	var bodies = $Area2D.get_overlapping_bodies()
	var d = Vector2(0,0)
	for b in bodies :
		if b is RigidBody2D:
			d = b.position - position
			b.apply_impulse(Vector2(0,0), ((1-smoothstep(0, distance_max, d.length())) * (boum_max-boum_min)+boum_min)*d.normalized())
	print("BOUM ! end")

func _on_Ball_body_entered(body):#Not yet managed because collision are hard for rigidbodies
	var collision_direction = position - body.position
	print("body entered : "+str(body.get_name())+" "+str(collision_direction)+" "+str(linear_velocity))
	if physics_enabled and collision_direction.normalized().dot(linear_velocity) > speed_threshold :
		print("BOUM ! debut")
		$CPUParticles2D.restart()
		for b in get_colliding_bodies():
			print(b.name)
		boum()
