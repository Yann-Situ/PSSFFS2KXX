extends Ball

# Constant energy ball, with infinite bouncing and no gravity
func _ready():
	$Sprite2D.texture = preload("res://assets/art/ball/ball_bouncy.png")
	self.mass = 1.2
	self.gravity_scale = 1.0
	self.set_friction(0.0)
	self.set_bounce(1.0)
	self.set_penetration(0.35)
