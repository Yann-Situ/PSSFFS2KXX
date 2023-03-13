extends GPUParticles2D

signal emission_finished

func start():
	if not emitting:
		emitting = true
		get_tree().create_timer(lifetime * (2 - explosiveness), false)
		super.connect("timeout",Callable(self,"_queue_free"))

func _queue_free():
	emission_finished.emit()
	queue_free()
