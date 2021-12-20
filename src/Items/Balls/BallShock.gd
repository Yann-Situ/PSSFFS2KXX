extends Ball

export (float) var shock_min = 401
export (float) var shock_max = 401 # m*pix/s
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

func apply_shock_impulse(shock_force : float, shock_global_position : Vector2, bodies):
	for b in bodies :
		if b != self:
			var momentum = (b.global_position - shock_global_position).normalized()
			momentum *= shock_force
			
			if b.is_in_group("electrics"):
				b.apply_shock(momentum)
				if b.get_parent().is_in_group("activables"):
					b.get_parent().toggle_activated(true)
			if b.is_in_group("physicbodies"):
				b.apply_impulse(momentum)
			elif b.is_in_group("breakables"):
				b.apply_explosion(momentum)

func shock(shock_force : float, shock_global_position : Vector2):
	if not $Timer.is_stopped():
		print(self.name + " is not yet ready for a new shock")
		return false
	$Timer.start(shock_timer)
	$ShockWaveAnim.global_position = shock_global_position
	$ShockWaveAnim.restart()
	$AnimationPlayer.play("shockwave")
	Global.camera.screen_shake(0.25,5)
	var bodies = $ShockZone.get_overlapping_bodies()+$ShockZone.get_overlapping_areas()
	apply_shock_impulse(shock_force, shock_global_position, bodies)
	print("shock !")

func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	if $Timer.is_stopped():
		if holder == player:
			if !player.S.is_jumping and player.S.is_crouching:
				player.apply_impulse(shock_jump*Vector2.UP)
				shock(shock_max, player.global_position+40*Vector2.DOWN)
			elif !player.S.is_onfloor and player.S.crouch_p:
				player.apply_impulse(shock_fall*Vector2.DOWN)
				shock(shock_max, player.global_position)
			else :
				shock(shock_max, player.global_position)
		else :
			shock(shock_min, self.global_position)
	
func power_jr(player,delta):
	pass

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shockwave":
		$AnimationPlayer.play("idle")
