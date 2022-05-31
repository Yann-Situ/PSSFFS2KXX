extends Particles2D

signal emission_finished

func start():
	if not emitting:
		emitting = true
		get_tree().create_timer(lifetime * (2 - explosiveness), false)\
			.connect("timeout", self, "_queue_free")
			
func _queue_free():
	emit_signal("emission_finished")
	queue_free()
