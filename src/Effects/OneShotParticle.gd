extends GPUParticles2D

signal emission_finished

func start():
	if not emitting:
		emitting = true
		self.timeout.connect(self._queue_free)
		get_tree().create_timer(lifetime * (2 - explosiveness), false)

func _queue_free():
	emission_finished.emit()
	queue_free()
