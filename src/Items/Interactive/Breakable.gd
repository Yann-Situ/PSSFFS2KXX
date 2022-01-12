extends CollisionObject2D
# in order to call the parent apply_impulse from breakable objects
func _ready():
	add_to_group("breakables")
	get_parent().add_to_group("breakables")

func apply_explosion(momentum : Vector2):
	if get_parent().has_method("apply_explosion"):
		return get_parent().apply_explosion(momentum)
	return false
