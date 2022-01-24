extends Ball

export (float) var damage = 3.0#lp
export (float) var boum_min = 400
export (float) var boum_max = 700 # m*pix/s
export (float) var distance_max = 64
export (float) var damage_distance_max = 128
export (float) var speed_threshold = 350#pix/s : if the difference of speed when collision is above this value, then boum !
export (float) var boum_timer = 1.0#s : minimum time between two consecutive boums.
export (float) var boum_delay = 0.13#s : time between boum_effect and apply_explosion

func _ready():
	self.mass = 1.2
	self.set_friction(0.15)
	self.set_bounce(0.3)
	$BoumZone/CollisionShape2D.shape.radius = distance_max

func apply_impulse(impulse : Vector2):
	linear_velocity += invmass * impulse
	if impulse.length_squared() >= boum_min*boum_min :
		boum(boum_min, self.global_position)
	
func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	if (linear_velocity-collider_velocity).length()>speed_threshold:
		boum(boum_min, collision_point)
	return true

func apply_boum_impulse(boum_force : float, boum_global_position : Vector2, bodies):
	var d = Vector2(0,0)
	for b in bodies :
		if b != self:
			d = b.global_position - boum_global_position
			if b.is_in_group("physicbodies"):
	#			b.apply_impulse(((1-smoothstep(0, distance_max, d.length())) * (boum_max-boum_min)+boum_min)*d.normalized())
				b.apply_impulse(boum_force*d.normalized())
			if b.is_in_group("breakables"):
				b.apply_explosion(boum_force*d.normalized())
			if b.is_in_group("damageables"):
				#if d.length_squared() < damage_distance_max*damage_distance_max:
				b.apply_damage(damage, 0.1)
			if b is Player:
				b.apply_impulse(boum_force*d.normalized())
	print(self.name+" BOUM !")

func boum(boum_force : float, boum_global_position : Vector2):
	if not $Timer.is_stopped():
		print(self.name + " is not yet ready for a new boum")
		return false
	$Timer.start(boum_timer)
	$BoumParticles.global_position = boum_global_position
	$ShockWaveAnim.global_position = boum_global_position
	$BoumParticles.restart()
	$ShockWaveAnim.restart()
	Global.camera.screen_shake(0.3,5)
	var bodies = $BoumZone.get_overlapping_bodies()+$BoumZone.get_overlapping_areas()
	yield(get_tree().create_timer(boum_delay), "timeout")
	apply_boum_impulse(boum_force, boum_global_position, bodies)
	return true

func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	if holder == player:
		boum(boum_max, player.global_position)
	else :
		boum(boum_min, self.global_position)
	
func power_jr(player,delta):
	pass

