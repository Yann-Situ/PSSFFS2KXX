extends Ball

@export var speed_threshold : float = 70##pix/s : if the impulse of collision is above this value, then boum !
@export var boum_timer : float = 1.0##s : minimum time between two consecutive boums.
@export var max_explosion_data : ExplosionData
@export var min_explosion_data : ExplosionData
@export var impulse_dash_boum : float = 800.0

func _ready():
	super()
	self.mass = 1.2
	assert(max_explosion_data != null)
	assert(min_explosion_data != null)
	max_explosion_data.path_exceptions = [self.get_path()]
	min_explosion_data.path_exceptions = [self.get_path()]

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).dot(collision_normal)
	if speed >= speed_threshold:
		boum(true, collision_point)
	if speed >= dust_threshold:
		$Visuals/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect)

func boum(use_min_explosion : bool, boum_global_position : Vector2):
	if not $BoumTimer.is_stopped():
		print(self.name + " is not yet ready for a new boum")
		return false
	$BoumTimer.start(boum_timer)
	$BoumParticles.global_position = boum_global_position
	$ShockWaveAnim.global_position = boum_global_position
	$BoumParticles.restart()
	$ShockWaveAnim.restart()
	Global.camera.screen_shake(0.3,5,global_position)

	if use_min_explosion:
		GlobalEffect.make_explosion(boum_global_position, min_explosion_data)
	else:
		GlobalEffect.make_explosion(boum_global_position, max_explosion_data)
	return true

func on_dunkdash_start(player):
	$BoumParticles.global_position = player.global_position
	$BoumParticles.restart()
	player.add_impulse(impulse_dash_boum*player.movement.velocity.normalized())

func on_dunkjump_start(player):
	$BoumParticles.global_position = player.effect_handler.global_position + 32.0*Vector2.DOWN
	$BoumParticles.restart()
	GlobalEffect.make_explosion(player.effect_handler.global_position + 8.0*Vector2.DOWN, min_explosion_data)
	
func on_destruction(): # call before changing holder, disable_physics and deleting selectors
	boum(true, self.global_position)

func _on_impulse(impulse : Vector2):
	if impulse.length() > speed_threshold*invmass:
		boum(true, self.global_position)

################################################################################

func power_p(player,delta):
	pass
func power_p_hold(player,delta):
	pass

func power_p_physics(player,delta):
	pass
func power_p_physics_hold(player,delta):
	pass

func power_jp(player,delta):
	boum(true, self.global_position)
func power_jp_hold(player,delta):
	boum(false, player.global_position)

func power_jr(player,delta):
	pass
func power_jr_hold(player,delta):
	pass
