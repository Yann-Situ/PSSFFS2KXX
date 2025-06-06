extends Ball

@export var shock_jump : float = 500 ## m*pix/s : jump impulse.
@export var shock_fall : float = 700 ## m*pix/s : fall impulse.
@export var shock_timer : float = 0.25##s : time before next shock possible.

@export var distortion_resource : DistortionResource
@export var explosion_data : ExplosionData
#explosion_data.body_explode.connect(self.apply_body_impulse)
#GlobalEffect.make_explosion(shock_global_position, explosion_data)

const CROUCH_SHOCK_OFFSET = Vector2(0.0,40.0)

func _ready():
	super()
	#$ShockZone/CollisionShape2D.shape.radius = distance_max
	$AnimationPlayer.play("idle")
	assert(explosion_data != null)
	explosion_data.path_exceptions = [self.get_path()]
	explosion_data.body_explode.connect(self.apply_body_impulse)

#func apply_shock_impulse(shock_force : float, shock_global_position : Vector2, bodies):
#	for b in bodies :# should be link to explosion_data.body_explode signal
#		if b != self:
#			apply_body_impulse(b, shock_force*(b.global_position - shock_global_position).normalized())

func apply_body_impulse(body : Node2D, direction : Vector2):
	if body.is_in_group("electrics"):
		body.apply_shock(explosion_data.momentum_electric*direction)
		if body.get_parent().is_in_group("activables"):
			body.get_parent().toggle_activated(true)
	if body.is_in_group("physicbodies") or body.is_in_group("situbodies"):
		# body.set_linear_velocity(Vector2.ZERO) # Old implementation
		# body.add_impulse(momentum) # Old implementation
		body.override_impulse(explosion_data.momentum_physicbody*direction)
	elif body.is_in_group("breakables"):
		body.apply_explosion(explosion_data.momentum_breakable*direction)


func shock(shock_global_position : Vector2):
	if not $Timer.is_stopped():
		print(self.name + " is not yet ready for a new shock")
		return false
	$Timer.start(shock_timer)
	Global.camera.screen_shake(0.25,5,global_position)
	$ShockWaveAnim.global_position = shock_global_position
	$ShockWaveAnim.restart()
	$AnimationPlayer.play("shockwave")
	shockwave_distortion(shock_global_position)
	#var bodies = $ShockZone.get_overlapping_bodies()+$ShockZone.get_overlapping_areas()
	#apply_shock_impulse(shock_force, shock_global_position, bodies)
	GlobalEffect.make_explosion(shock_global_position, explosion_data)
	print("shock !")

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "shockwave":
		$AnimationPlayer.play("idle")

func shockwave_distortion(distortion_glob_position : Vector2):
	distortion_resource.make_instance(distortion_glob_position)
	#GlobalEffect.make_distortion(distortion_glob_position, 0.5,\
	#	"fast", Vector2(110,110), 250)

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
	shock(self.global_position)
func power_jp_hold(player,delta):
	if $Timer.is_stopped():
		if player.S.jump.can and player.S.crouch.ing and player.S.down.pressed:
			player.add_impulse(shock_jump*Vector2.UP)
			shock(player.global_position+CROUCH_SHOCK_OFFSET)
			GlobalEffect.make_ground_wave(player.effect_handler.global_position, 1.0, "subtle")
		elif !player.S.floor.ing and player.S.down.pressed:
			player.add_impulse(shock_fall*Vector2.DOWN)
			shock(player.global_position)
		else :
			shock(player.global_position)

func power_jr(player,delta):
	pass
func power_jr_hold(player,delta):
	pass
