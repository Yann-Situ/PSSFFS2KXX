extends Ball

export (float) var boum_min = 400
export (float) var boum_max = 700 # m*pix/s
export (float) var distance_max = 64
export (float) var speed_threshold = 350
export (float) var boum_timer = 1.0#s

func _ready():
	self.mass = 1.2
	self.set_friction(0.15)
	self.set_bounce(0.3)
	$BoumZone/CollisionShape2D.shape.radius = distance_max

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	if (linear_velocity-collider_velocity).length()>speed_threshold:
		if $Timer.is_stopped():
			boum()
	return true

func apply_boum_impulse(boum_force : float):
	$Timer.start(boum_timer)
	var bodies = $BoumZone.get_overlapping_bodies()
	var d = Vector2(0,0)
	for b in bodies :
		d = b.global_position - self.global_position
		if b.is_in_group("physicbodies"):
#			b.apply_impulse(((1-smoothstep(0, distance_max, d.length())) * (boum_max-boum_min)+boum_min)*d.normalized())
			b.apply_impulse(boum_force*d.normalized())
		elif b.is_in_group("breakables"):
			b.apply_impulse(boum_force*d.normalized())
		elif b is Player:
			b.S.velocity += boum_force*d.normalized()

func boum():
	$BoumParticle.restart()
	Global.camera.screen_shake(0.3,5)
	apply_boum_impulse(boum_min)
	print("BOUM !")

func megaboum():
	$BoumParticle.restart()
	Global.camera.screen_shake(0.4,8)
	apply_boum_impulse(boum_max)
	print("MEGABOUM !")

func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	if $Timer.is_stopped():
		if holder == player:
			megaboum()
		else :
			boum()
	
func power_jr(player,delta):
	pass

