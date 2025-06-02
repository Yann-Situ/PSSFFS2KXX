extends Ball
# Yoyo ball, go back in hands after throwing

#@export var attract_speed = 350#pix/s
@export var follow_player_damping : float = 0.25# pix/pix
@export var follow_player_speed : float = 500# pix/s
@export var radius_stop_follow_player : float = 24.0# pix
@export var follow_ball_damping : float = 0.4# pix/pix
@export var follow_ball_speed : float = 600# pix/s
@export var radius_stop_follow_ball : float = 40.0# pix
@export var follow_ball_max_recall_duration : float = 0.8# s
@export var destruction_momentum = 800##kg*pix/s

var friction_save
var collision_mask_save_ : int = collision_mask
@onready var tween_ball_follow_player : Tween
@onready var tween_player_follow_ball : Tween
@onready var last_holder_2D : Node2D = null
@onready var last_player : Player = null

var player_global_position_save : Vector2

func _ready():
	super()
	tween_ball_follow_player = get_tree().create_tween().set_loops()
	tween_ball_follow_player.tween_callback(self.follow_last_holder).set_delay(0.06)
	tween_ball_follow_player.stop()
	
	tween_player_follow_ball = get_tree().create_tween().set_loops()
	tween_player_follow_ball.tween_callback(self.player_follow_self).set_delay(0.06)
	tween_player_follow_ball.stop()

################################################################################

func follow_last_holder() -> void:
	if last_holder_2D:
		var d = (last_holder_2D.global_position - self.global_position)
		if d.length() < radius_stop_follow_player:
			stop_recall()
		else:
			self.linear_velocity = lerp(self.linear_velocity, follow_player_speed*d.normalized(), follow_player_damping)

func player_follow_self() -> void: # WIP, very buggy, should be implemented using follow_state
	if tween_player_follow_ball.get_total_elapsed_time() > follow_ball_max_recall_duration:
		stop_recall_player()
		return
	if last_player is Player:
		var d = (player_global_position_save - last_player.global_position)
		if d.length() < radius_stop_follow_ball:
			stop_recall_player()
		else:
			last_player.movement.velocity = lerp(last_player.movement.velocity, follow_ball_speed*d.normalized(), follow_ball_damping)

func recall():
	if !is_belonging() and !tween_ball_follow_player.is_running():
		$Visuals/SpeedParticles.restart()
		#$Visuals/SpeedParticles.emitting = true
		#disable_physics()
		collision_mask_save_ = collision_mask
		collision_mask = 0
		tween_ball_follow_player.play()
		GlobalEffect.make_impact(self.global_position, impact_effect)
		if has_accel(Global.gravity_alterer) :
			remove_accel(Global.gravity_alterer)

func stop_recall():
	tween_ball_follow_player.stop()
	collision_mask = collision_mask_save_
	$Visuals/SpeedParticles.emitting = false
	if !has_accel(Global.gravity_alterer) :
		add_accel(Global.gravity_alterer)
		
func recall_player():
	if last_player is Player and !tween_player_follow_ball.is_running():
		if !last_player.get_state_node().dunk.ing:
			$Visuals/SpeedParticles.restart()
			tween_player_follow_ball.play()
			print("PLAYER YOYO RECALL")
			#if last_player.has_accel(Global.gravity_alterer) :
				#last_player.remove_accel(Global.gravity_alterer)
		else:
			push_warning("Yoyo recall_player but player dunk.ing")

func stop_recall_player():
	tween_player_follow_ball.stop()
	$Visuals/SpeedParticles.emitting = false
	if last_player is Player:
		print("PLAYER YOYO STOP RECALL")
		#if !last_player.has_accel(Global.gravity_alterer) :
			#last_player.add_accel(Global.gravity_alterer)
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
	if player is Player:
		last_player = player
		print("PLAYER YOYO START")
		player_global_position_save = player.global_position
		player.effect_handler.ghost_start(0.6, 0.1, Color.BLACK, get_dash_gradient())
		await get_tree().create_timer(0.6).timeout
		recall_player()

func power_jr(player,delta):
	pass
func power_jr_hold(player,delta):
	pass
