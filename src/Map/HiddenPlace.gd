extends TileMap

@export var transition_duration : float = 0.5#s

var tween_modulate : Tween

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func hide_behind(arg = null):
	if tween_modulate:
		tween_modulate.kill()
	tween_modulate = self.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_modulate.tween_property(self, "modulate", Color.WHITE, transition_duration)
	# twee_modulate.start() start automatically
func reveal_behind(arg = null):
	if tween_modulate:
		tween_modulate.kill()
	tween_modulate = self.create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween_modulate.tween_property(self, "modulate", Color.TRANSPARENT, transition_duration)
	# twee_modulate.start() start automatically
	
