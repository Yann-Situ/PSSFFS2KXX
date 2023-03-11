extends Sprite2D

@export (Gradient) var gradient
@export (bool) var use_gradient = false
var initial_alpha = 1.0
var final_alpha = 0.0
var duration = 1.0#s

func _ready():
	$Tween.interpolate_property(self, "modulate:a", initial_alpha, final_alpha, 0.5*duration, 2, 0.5*duration)
	if use_gradient :
		assert(gradient != null)
		$Tween.interpolate_method(self, "set_modulate_rgb_from_gradient", 0.0, 1.0, 0.5*duration, 2, 0.5*duration)
	$Tween.start()

func set_modulate_rgb_from_gradient(t : float) -> void:
	self_modulate = gradient.sample(t)

func _on_Tween_tween_completed(object, key):
	queue_free()
