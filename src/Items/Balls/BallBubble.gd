extends Ball
# Constant energy ball, with infinite bouncing and no gravity

var trail_scene = preload("res://src/Effects/Trail.tscn")

func _ready():
	self.mass = 1.5
	set_gravity_scale(0.0)
	self.set_friction(0.0)
	self.set_bounce(1.0)
	#$Sprite.set_material(preload("res://assets/shader/material/hologram_shadermaterial.tres"))
	#$Sprite.set_material($Sprite.get_material().duplicate())

func power_p(player,delta):
	pass

func power_jp(player,delta):
	if holder != player :
		throw(position, Vector2.ZERO)
		disable_physics()
		#$Tween.interpolate_property(self, "position", position, player.position, 0.1)
		$Tween.follow_property(self, "position", position, player, "position", 0.1)
		$Tween.start()
		var trail_instance = trail_scene.instance()
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
		# Warning: We're not calling $Sprite.add_child(trail_instance) because
		# the ball can be reparented during the tween of the trail, which
		# results in canceling the tween. (see https://www.reddit.com/r/godot/comments/vjkaun/reparenting_node_without_removing_it_from_tree/)
		$Animation.play("teleport")
	else :
		player.position.y -= 100

func power_jr(player,delta):
	pass

func _on_Tween_tween_all_completed():
	if holder == Global.get_current_room() :
		enable_physics()
	#position == player.position
