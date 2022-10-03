extends CollisionObject2D
# in order to call the parent apply_shock from electric objects
func _ready():
	add_to_group("electrics")
	#get_parent().add_to_group("electrics")

func apply_shock(momentum : Vector2):
	if get_parent().has_method("apply_shock"):
		get_parent().apply_shock(momentum)
