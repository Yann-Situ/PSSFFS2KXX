extends "res://src/Ball/Ball.gd"
# Constant energy ball, with infinite bouncing and no gravity
func _ready():
	$Sprite.texture = preload("res://assets/art/ball/ball_nogravity.png")
	self.mass = 1.2
	self.gravity_scale = 0.0
	self.set_friction(0.0)
	self.set_bounce(1.0)
	$Sprite.material = preload("res://assets/shader/speed_shadermaterial.tres")
	
func _physics_process(delta):
	$Sprite.material.set("shader_param/speed",self.linear_velocity)
