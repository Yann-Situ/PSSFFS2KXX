extends Ball
# Rolling Heavy ball, with no bouncing and large mass
func _ready():
	$Sprite.texture = preload("res://assets/art/ball/ball_rolling.png")
	self.mass = 2.0
	self.set_friction(0.0)
	self.set_bounce(0.001)
