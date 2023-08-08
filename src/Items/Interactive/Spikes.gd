extends Node2D

@export var damage : float = 1.5#lp
@export var damage_duration : float = 0.0#s

func _ready():
	self.z_index = Global.z_indices["foreground_4"]
	
func deal_damage(body : Node2D):
	if body.is_in_group("damageables"):
		body.apply_damage(damage, damage_duration)
