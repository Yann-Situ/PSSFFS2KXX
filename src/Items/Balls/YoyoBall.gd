extends Ball
# Yoyo ball, go back in hands after throwing

#@export var attract_speed = 350#pix/s
@export var follow_damping : float = 0.4# pix/pix
@export var follow_speed : float = 500# pix/s
@export var radius_stop_follow : float = 16.0# pix
@export var destruction_momentum = 800##kg*pix/s

var friction_save
var collision_mask_save_ : int = collision_mask
@onready var tween_follow : Tween
@onready var last_holder_2D : Node2D = null

func _ready():
	super()
	tween_follow = get_tree().create_tween().set_loops()
	tween_follow.tween_callback(self.follow_last_holder).set_delay(0.1)
	tween_follow.stop()

################################################################################

func follow_last_holder() -> void:
	if last_holder_2D:
		var d = (last_holder_2D.global_position - self.global_position)
		if d.length() < radius_stop_follow:
			stop_recall()
		else:
			self.linear_velocity = lerp(self.linear_velocity, follow_speed*d.normalized(), follow_damping)
		
func recall():
	if !is_belonging() and !tween_follow.is_running():
		$Visuals/SpeedParticles.restart()
		#$Visuals/SpeedParticles.emitting = true
		#disable_physics()
		collision_mask_save_ = collision_mask
		collision_mask = 0
		tween_follow.play()
		GlobalEffect.make_impact(self.global_position, impact_effect)
		if has_accel(Global.gravity_alterer) :
			remove_accel(Global.gravity_alterer)

func stop_recall():
	tween_follow.stop()
	collision_mask = collision_mask_save_
	$Visuals/SpeedParticles.emitting = false
	if !has_accel(Global.gravity_alterer) :
		add_accel(Global.gravity_alterer)
################################################################################

func collision_effect(collider, collider_velocity, collision_point, collision_normal):
	var speed = (linear_velocity-collider_velocity).dot(collision_normal)
	if speed >= dust_threshold:
		$Visuals/DustParticle.restart()
		if speed >= impact_threshold:
			GlobalEffect.make_impact(collision_point, impact_effect)
	if collider.is_in_group("breakables"):
		var has_explode = collider.apply_explosion(-destruction_momentum * collision_normal)
		#add_impulse(mass*linear_velocity) # rebond or not rebond

func on_pickup(holder):
	stop_recall()
func on_throw(previous_holder):
	if previous_holder is Node2D:
		last_holder_2D = previous_holder
	await get_tree().create_timer(1.2).timeout
	recall()
	

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
	recall()
func power_jp_hold(player,delta):
	pass
		

func power_jr(player,delta):
	pass
func power_jr_hold(player,delta):
	pass
