extends GPUParticles2D

signal emission_finished
@export var offset : Vector2 = Vector2.ZERO

func start(normal : Vector2 = Vector2.UP):
	if not emitting:
		var angle = Vector2.UP.angle_to(normal)
		self.global_position += offset.rotated(angle)
		self.rotation = angle
		emitting = true
		await get_tree().create_timer(lifetime * (2 - explosiveness), false).timeout
		_queue_free()

func _queue_free():
	emission_finished.emit()
	queue_free()
