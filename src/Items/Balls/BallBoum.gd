extends Ball

export (float) var boum_min = 250
export (float) var boum_max = 400 # m*pix/s
export (float) var distance_max = 64
export (float) var speed_threshold = 350

func _ready():
	self.mass = 1.2
	self.set_friction(0.15)
	self.set_bounce(0.3)
	$BoumZone/CollisionShape2D.shape.radius = distance_max

func collision_effect(collision):
	if (linear_velocity-collision.collider_velocity).length()>speed_threshold:
		boum()
	return true
	
func boum():
	$BoumParticle.restart()
	Global.camera.screen_shake(0.3,5)
	var bodies = $BoumZone.get_overlapping_bodies()
	var d = Vector2(0,0)
	for b in bodies :
		if b is PhysicBody:
			d = b.position - position
#			b.apply_impulse(((1-smoothstep(0, distance_max, d.length())) * (boum_max-boum_min)+boum_min)*d.normalized())
			b.apply_impulse(boum_max*d.normalized())
		elif b.is_in_group("breakables"):
			print("BREAKOUT")
			b.apply_impulse(boum_max*d.normalized())
	print("BOUM !")

func megaboum():
	$BoumParticle.restart()
	Global.camera.screen_shake(0.4,8)
	var bodies = $BoumZone.get_overlapping_bodies()
	var d = Vector2(0,0)
	for b in bodies :
		if b is PhysicBody:
			d = b.position - position
			b.apply_impulse(((1-smoothstep(0, distance_max, d.length())) * (2*boum_max-2*boum_min)+2*boum_min)*d.normalized())
	print("MEGABOUM !")

func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	if holder == player:
		megaboum()
	else :
		boum()
	
func power_jr(player,delta):
	pass

