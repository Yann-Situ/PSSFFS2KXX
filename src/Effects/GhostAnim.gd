extends Sprite2D

@export var gradient : Gradient
@export var use_gradient : bool = false
var initial_alpha = 1.0
var final_alpha = 0.0
var duration = 1.0#s

func _ready():
	var tween = self.create_tween().set_parallel(true)
	tween.tween_method(self.set_modulate_a, 0.0, 1.0, 0.75*duration)\
	.set_delay(0.25*duration).set_ease(Tween.EASE_IN)
	if use_gradient :
		assert(gradient != null)
		tween.tween_method(self.set_modulate_rgb_from_gradient, 0.0, 1.0, duration)\
		.set_trans(Tween.TRANS_SINE)
	tween.chain().tween_callback(self.queue_free)
	# tween.start() now starts automatically

func set_modulate_rgb_from_gradient(t : float) -> void:
	self.material.set_shader_parameter("modulate", gradient.sample(t))

func set_modulate_a(t : float) -> void:
	self.material.set_shader_parameter("alpha", (1-t)*initial_alpha + t*final_alpha)
