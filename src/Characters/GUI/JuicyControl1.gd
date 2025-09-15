extends Label
class_name JuicyControl1

@export var shake_strength := 8
@export var shake_times := 4

var tween : Tween

func juicy_show(auto_hide : bool = false):
	# Stop any existing tweens
	if tween:
		tween.kill()
	tween = create_tween()

	# Set the text and animate it
	self.visible = true
	self.scale = Vector2(0.5, 0.5)
	self.modulate.a = 0.0
	self.position = Vector2.ZERO

	# Animate text pop-in (scale + fade in)
	tween.tween_property(self, "modulate:a", 1.0, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2(1.2, 1.2), 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	# Add screen shake
	for i in range(shake_times):
		var angle = randf_range(0.0, TAU)
		var direction = Vector2(cos(angle), sin(angle))
		var offset = direction * shake_strength
		tween.parallel().tween_property(self, "position", offset, 0.03).set_delay(0.25 + i * 0.03)
	tween.parallel().tween_property(self, "position", Vector2.ZERO, 0.05).set_delay(0.25 + shake_times * 0.03)
	tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.15)

	# Optional: Auto hide
	if auto_hide:
		tween.tween_interval(1.0)
		tween.tween_callback(Callable(self, "juicy_hide"))

func juicy_update():
	# Animate out current text (if visible)
	if self.visible:
		# Stop any existing tweens
		if tween:
			tween.kill()
		tween = create_tween()
		tween.tween_property(self, "scale", Vector2(1.2, 1.2), 0.05).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		# Add screen shake
		for i in range(shake_times):
			var angle = randf_range(0.0, TAU)
			var direction = Vector2(cos(angle), sin(angle))
			var offset = direction * shake_strength
			tween.parallel().tween_property(self, "position", offset, 0.03).set_delay(0.25 + i * 0.03)
		tween.parallel().tween_property(self, "position", Vector2.ZERO, 0.05).set_delay(0.25 + shake_times * 0.03)
		tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.15)
	else:
		juicy_show()

func juicy_hide():
	# Fade out and shrink
	# Stop any existing tweens
	if tween:
		tween.kill()
	tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.5).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(self, "scale", Vector2(0.5, 0.5), 0.5).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_callback(Callable(self, "_on_hidden"))

func _on_hidden():
	self.visible = false
