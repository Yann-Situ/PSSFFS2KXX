extends Ball
# Constant energy ball, with infinite bouncing and no gravity
func _ready():
	self.mass = 1.5
	set_gravity_scale(0.0)
	self.set_friction(0.0)
	self.set_bounce(1.0)
	#$Sprite.set_material(preload("res://assets/shader/material/hologram_shadermaterial.tres"))
	#$Sprite.set_material($Sprite.get_material().duplicate())

	$Effects/TrailHandler.set_node_to_trail(self)

func power_p(player,delta):
	pass

func power_jp(player,delta):
	if holder != player :
		throw(position, Vector2.ZERO)
		disable_physics()
		#$Tween.interpolate_property(self, "position", position, player.position, 0.1)
		$Tween.follow_property(self, "position", position, player, "position", 0.1)
		$Tween.start()
		$Effects/TrailHandler.start(0.1,0.0015)
		$Animation.play("teleport")
	else :
		player.position.y -= 100

func power_jr(player,delta):
	pass

func _on_Tween_tween_all_completed():
	if holder == null :
		enable_physics()
	#position == player.position
