extends Ball
# Yoyo ball, go back in hands after throwing

#@export var attract_speed = 350#pix/s
@export var follow_damping : float = 0.7# pix/pix
@export var follow_speed : float = 250# pix/s
@export var follow_delay : float = 0.7# s

@onready var tween_follow : Tween
@onready var last_holder_2D : Node2D = self

func _ready():
	super()
	tween_follow = get_tree().create_tween().set_loops()
	tween_follow.tween_callback(self.follow_last_holder).set_delay(follow_delay)
	tween_follow.stop()

################################################################################

func follow_last_holder() -> void:
	if !last_holder_2D:
		update_last_holder()
	if last_holder_2D:
		var d = (last_holder_2D.global_position - self.global_position)
		self.linear_velocity = lerp(self.linear_velocity, follow_speed*d.normalized(), follow_damping)
func recall():
	if !is_belonging() and !tween_follow.is_running():
		$Visuals/SpeedParticles.restart()
		#$Visuals/SpeedParticles.emitting = true
		#disable_physics()
		tween_follow.play()
		GlobalEffect.make_impact(self.global_position, impact_effect)

func stop_recall():
	tween_follow.stop()
	$Visuals/SpeedParticles.emitting = false
################################################################################

func on_pickup(holder):
	stop_recall()
func on_throw(previous_holder):
	await get_tree().create_timer(1.0).timeout
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
	last_holder_2D = player
	follow_last_holder()
func power_jp_hold(player,delta):
	pass
		

func power_jr(player,delta):
	pass
func power_jr_hold(player,delta):
	pass


func _on_player_detector_body_entered(body: Node2D) -> void:
	last_holder_2D = body
	recall()

func update_last_holder() -> void:
	if $PlayerDetector.has_overlapping_bodies():
		last_holder_2D = $PlayerDetector.get_overlapping_bodies()[0]
	else:
		last_holder_2D = null
		stop_recall()
