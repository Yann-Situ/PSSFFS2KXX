extends StaticBody2D
# in order to call the parent apply_impulse from breakable objects
func _ready():
	add_to_group("breakables")
	
func apply_impulse(momentum : Vector2):
	get_parent().apply_impulse(momentum)
