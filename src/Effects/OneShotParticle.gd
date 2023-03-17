extends GPUParticles2D

signal emission_finished

func start():
	if not emitting:
		emitting = true
		await get_tree().create_timer(lifetime * (2 - explosiveness), false).timeout
		_queue_free()

func _queue_free():
	emission_finished.emit()
	queue_free()
