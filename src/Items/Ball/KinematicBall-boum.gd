extends KinematicBall

export (float) var boum_min = 100
export (float) var boum_max = 600 # m*pix/s
export (float) var distance_max = 48
export (float) var speed_threshold = 350

# Heavy ball, with no bouncing and large mass
func _ready():
	pass

func collision_effect(collision):
	if (velocity-collision.collider_velocity).length()>speed_threshold:
		boum()
		
func boum():
	$BoumParticle.restart()
	Global.camera.screen_shake(0.3,5)
	var bodies = $BoumZone.get_overlapping_bodies()
	var d = Vector2(0,0)
	for b in bodies :
		if b is PhysicBody:
			d = b.position - position
			b.apply_impulse(((1-smoothstep(0, distance_max, d.length())) * (boum_max-boum_min)+boum_min)*d.normalized())
	print("BOUM !")
