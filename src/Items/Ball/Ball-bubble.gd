extends Ball
# Constant energy ball, with infinite bouncing and no gravity
func _ready():
	self.mass = 1.5
	self.gravity_scale = 0.0
	self.gravity = 0.0
	self.set_friction(0.0)
	self.set_bounce(1.0)
	$Sprite.set_material(preload("res://assets/shader/material/hologram_shadermaterial.tres"))
	$Sprite.set_material($Sprite.get_material().duplicate())
