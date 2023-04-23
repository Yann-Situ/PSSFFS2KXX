extends Ball

@export var damage : float = 3.0#lp
@export var boum_min : float = 400.0
@export var boum_max : float = 700.0 # m*pix/s
@export var distance_max : float = 64.0
@export var speed_threshold : float = 70#pix/s : if the impulse of collision is above this value, then boum !
@export var boum_timer : float = 1.0#s : minimum time between two consecutive boums.
@export var boum_delay : float = 0.13#s : time between boum_effect and apply_explosion

func _ready():
	super()
	self.mass = 1.2
	$BoumZone/CollisionShape2D.shape.radius = distance_max

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).dot(collision_normal)
	if speed >= speed_threshold:
		boum(boum_min, collision_point)
	if speed >= dust_threshold:
		$Effects/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect)

# func apply_boum_impulse(boum_force : float, boum_global_position : Vector2, bodies):
# 	var d = Vector2(0,0)
# 	for b in bodies :
# 		if b != self:
# 			d = b.global_position - boum_global_position
# 			if b.is_in_group("physicbodies"):
# 	#			b.add_impulse(((1-smoothstep(0, distance_max, d.length())) * (boum_max-boum_min)+boum_min)*d.normalized())
# 				b.add_impulse(boum_force*d.normalized())
# 			if b.is_in_group("breakables"):
# 				b.apply_explosion(boum_force*d.normalized())
# 			if b.is_in_group("damageables"):
# 				#if d.length_squared() < damage_distance_max*damage_distance_max:
# 				b.apply_damage(damage, 0.1)
# 			if b is Player:
# 				b.add_impulse(boum_force*d.normalized())
# 	print(self.name+" BOUM !")

func boum(boum_force : float, boum_global_position : Vector2):
	if not $Timer.is_stopped():
		print(self.name + " is not yet ready for a new boum")
		return false
	$Timer.start(boum_timer)
	$BoumParticles.global_position = boum_global_position
	$ShockWaveAnim.global_position = boum_global_position
	$BoumParticles.restart()
	$ShockWaveAnim.restart()
	Global.camera.screen_shake(0.3,5,global_position)
	
	var boum_impulse = 1.2*boum_force
	GlobalEffect.make_simple_explosion(boum_global_position, distance_max, \
	0.1, 4, [boum_force, 0.0, boum_impulse], damage, 0.1, [self])
	# var bodies = $BoumZone.get_overlapping_bodies()+$BoumZone.get_overlapping_areas()
	# await get_tree().create_timer(boum_delay).timeout
	# apply_boum_impulse(boum_force, boum_global_position, bodies)
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

func on_destruction(): # call before changing holder, disable_physics and deleting selectors
	boum(boum_min, self.global_position)

func _on_impulse(impulse : Vector2):
	if impulse.length() > speed_threshold*invmass:
		boum(boum_min, self.global_position)
