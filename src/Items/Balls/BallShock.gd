extends Ball

export (float) var shock_min = 401
export (float) var shock_max = 401 # m*pix/s
export (float) var shock_jump = 1850 # m*pix/s
export (float) var shock_fall = 5000 # m*pix/s
export (float) var distance_max = 64
export (float) var shock_timer = 0.25#s

var distortion_scene = preload("res://src/Effects/Distortion.tscn") 

func _ready():
	self.mass = 1.15
	self.set_friction(0.12)
	self.set_bounce(0.35)
	$ShockZone/CollisionShape2D.shape.radius = distance_max
	$AnimationPlayer.play("idle")

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
				b.set_linear_velocity(Vector2.ZERO)
				b.apply_impulse(momentum)
			elif b.is_in_group("breakables"):
				b.apply_explosion(momentum)

func shock(shock_force : float, shock_global_position : Vector2):
	if not $Timer.is_stopped():
		print(self.name + " is not yet ready for a new shock")
		return false
	$Timer.start(shock_timer)
	Global.camera.screen_shake(0.25,5)
	$ShockWaveAnim.global_position = shock_global_position
	$ShockWaveAnim.restart()
	$AnimationPlayer.play("shockwave")
	shockwave_distortion(shock_global_position)
	var bodies = $ShockZone.get_overlapping_bodies()+$ShockZone.get_overlapping_areas()
	apply_shock_impulse(shock_force, shock_global_position, bodies)
	print("shock !")

func power_p(player,delta):
	pass
	
func power_jp(player,delta):
	if $Timer.is_stopped():
		if holder == player:
			if player.S.can_jump and player.S.is_crouching:
				if player.has_node("Actions/Jump"):
					player.get_node("Actions/Jump").move(0.001,-player.invmass*shock_jump)
				else :
					printerr("In "+name+" : player doesn't have a node Actions/Jump")
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

func shockwave_distortion(glob_pos : Vector2):
	var distortion = distortion_scene.instance()
	distortion.animation_delay = 0.5#s
	distortion.z_index = 250
	distortion.global_position = glob_pos
	get_parent().add_child(distortion)
	distortion.start("fast")
