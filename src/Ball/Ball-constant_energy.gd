extends "res://src/Ball/Ball.gd"
# Constant energy ball, with infinite bouncing and no gravity

func integrate_forces_child(state):
	if physics_enabled:
		$Particles.visible = true
	else :
		$Particles.visible = false
