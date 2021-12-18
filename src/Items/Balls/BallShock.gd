extends Ball

export (float) var shock_min = 400
export (float) var shock_max = 400 # m*pix/s
export (float) var shock_jump = 2300 # m*pix/s
export (float) var shock_fall = 5000 # m*pix/s
export (float) var distance_max = 64
export (float) var shock_timer = 0.25#s

func _ready():
	self.mass = 1.15
	self.set_friction(0.12)
	self.set_bounce(0.35)
	$ShockZone/CollisionShape2D.shape.radius = distance_max
	$AnimationPlayer.play("idle")

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	return true

func apply_shock_impulse(shock_force : float):
	$Timer.start(shock_timer)
	var bodies = $ShockZone.get_overlapping_bodies()+$ShockZone.get_overlapping_areas()
	
	for b in bodies :
		var momentum = (b.global_position - self.global_position).normalized()
		momentum *= shock_force
		
		if b.is_in_group("electrics"):
			b.apply_shock(momentum)
			if b.get_parent().is_in_group("activables"):
				b.get_parent().toggle_activated(true)
		if b.is_in_group("physicbodies"):
			b.apply_impulse(momentum)
		elif b.is_in_group("breakables"):
			b.apply_explosion(momentum)
		if b is Player :
			if not holder is Player:
				b.apply_impulse(momentum)
			else :
				if !b.S.is_jumping and b.S.is_crouching:
					b.apply_impulse(shock_jump*Vector2.UP)
				elif !b.S.is_onfloor and b.S.crouch_p:
					b.apply_impulse(shock_fall*Vector2.DOWN)

func shock():
	$AnimationPlayer.play("shockwave")
	$ShockWaveAnim.restart()
	Global.camera.screen_shake(0.25,5)
	apply_shock_impulse(shock_min)
	print("shock !")

func megashock():
	$AnimationPlayer.play("shockwave")
	$ShockWaveAnim.restart()
	Global.camera.screen_shake(0.25,5)
	apply_shock_impulse(shock_max)
	print("MEGAshock !")

func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	if $Timer.is_stopped():
		if holder == player:
			megashock()
		else :
			shock()
	
func power_jr(player,delta):
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shockwave":
		$AnimationPlayer.play("idle")
