extends CollisionObject2D
# in order to call the parent apply_damage from damageable objects
func _ready():
	add_to_group("damageables")
	get_parent().add_to_group("damageables")

func apply_damage(damage : float):
	if get_parent().has_method("apply_damage"):
		get_parent().apply_damage(damage)
