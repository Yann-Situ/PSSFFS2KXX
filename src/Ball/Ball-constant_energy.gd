extends "res://src/Ball/Ball.gd"
# Constant energy ball, with infinite bouncing and no gravity
func _ready():
	$Sprite.texture = preload("res://assets/art/ball/ball_nogravity.png")
	self.mass = 1.2
	self.gravity_scale = 0.0
	self.set_friction(0.0)
	self.set_bounce(1.0)
	$Sprite.set_material(preload("res://assets/shader/material/hologram_shadermaterial.tres"))
	$Sprite.set_material($Sprite.get_material().duplicate())

