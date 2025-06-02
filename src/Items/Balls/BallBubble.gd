extends Ball
# Constant energy ball, with infinite bouncing and no gravity

var trail_scene = preload("res://src/Effects/Trail.tscn")
@onready var player_speed_save : Vector2 = Vector2.ZERO

func _ready():
	super()
	remove_accel(Global.gravity_alterer)
	#$Visuals.set_material(preload("res://assets/shader/material/hologram_shadermaterial.tres"))
	#$Visuals.set_material($Visuals.get_material().duplicate())

func make_electric_trail():
	var trail_instance = trail_scene.instantiate()
	# TODO trail resource ?
	trail_instance.lifetime = 0.1
	trail_instance.wildness_amplitude = 250.0
	trail_instance.wildness_tick = 0.02
	trail_instance.trail_fade_time = 0.1
	trail_instance.point_lifetime = 0.25
	trail_instance.addpoint_tick = 0.005
	trail_instance.width = 8.0
	trail_instance.gradient = get_main_gradient()
	trail_instance.autostart = true
	trail_instance.node_to_trail = self
	Global.get_current_room().add_child(trail_instance)
	# Warning: We're not calling $Visuals.add_child(trail_instance) because
	# the ball can be reparented during the tween of the trail, which
	# results in canceling the tween. (see https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/)

func tween_follow_property(t : float, src_pos : Vector2, trg : Node2D) -> void:
	self.global_position = src_pos.lerp(trg.global_position,t)

func _on_tween_completed():
	if !is_belonging():
		enable_physics()
	#position == player.position

func on_throw(previous_holder : Node):
	make_electric_trail()
func on_dunkdash_start(player):
	make_electric_trail()
	make_electric_trail()

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
	disable_physics()
	var tween = self.create_tween() # problems when the ball is not in scenetree
	tween.tween_method(self.tween_follow_property.bind(global_position,player),\
	0.0, 1.0, 0.16)
	tween.tween_callback(self._on_tween_completed)
	# tween.start()

	throw(global_position, Vector2.ZERO)
	$Animation.play("teleport")
func power_jp_hold(player,delta):
	make_electric_trail()
	make_electric_trail()
	make_electric_trail()
	player_speed_save = player.movement.velocity
	player.movement.speed_scale = 0.0
	$Animation.play("stase")

func power_jr(player,delta):
	player.movement.velocity = player_speed_save
	player.movement.speed_scale = 1.0
func power_jr_hold(player,delta):
	player.movement.velocity = player_speed_save
	player.movement.speed_scale = 1.0
