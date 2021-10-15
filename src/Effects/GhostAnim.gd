extends Sprite

var initial_alpha = 1.0
var final_alpha = 0.0
var duration = 1.0#s

func _ready():
	$Tween.interpolate_property(self, "modulate:a", initial_alpha, final_alpha, 0.5*duration, 2, 0.5*duration)
	$Tween.start()



func _on_Tween_tween_completed(object, key):
	queue_free()
