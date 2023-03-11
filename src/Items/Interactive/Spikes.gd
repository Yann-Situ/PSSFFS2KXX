extends Node2D

@export (float) var damage = 1.5#lp
@export (float) var damage_duration = 0.0#s

func _ready():
	self.z_index = Global.z_indices["foreground_4"]
	
func deal_damage(body : Node2D):
	if body.is_in_group("damageables"):
		body.apply_damage(damage, damage_duration)
