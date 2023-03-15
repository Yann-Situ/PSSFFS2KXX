extends Sprite2D

@export var gradient : Gradient
@export var use_gradient : bool = false
var initial_alpha = 1.0
var final_alpha = 0.0
var duration = 1.0#s

func _ready():
	var tween = self.create_tween().set_parallel(true)
	tween.tween_property(self, "modulate:a", final_alpha, 0.5*duration)\
	.from(initial_alpha)\
	.set_delay(0.5*duration)

	if use_gradient :
		assert(gradient != null)
		tween.tween_method(self.set_modulate_rgb_from_gradient, 0.0, 1.0, 0.5*duration)\
		.set_delay(0.5*duration)
	tween.chain().tween_callback(self.queue_free)
	# tween.start() now starts automatically

func set_modulate_rgb_from_gradient(t : float) -> void:
	self_modulate = gradient.sample(t)
