extends "res://src/Ball/Ball.gd"
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	$Sprite.texture = preload("res://assets/art/ball/ball_heavy.png")
	self.mass = 2.0
	self.set_friction(0.0)
	self.set_bounce(0.001)
	$Sprite.material = preload("res://assets/shader/material/speed_ball_shadermaterial.tres")
	$Sprite.material.set("shader_param/max_speed",300)
	$Sprite.set_material($Sprite.get_material().duplicate())
	
func _physics_process(delta):
	$Sprite.material.set("shader_param/speed",self.linear_velocity)
