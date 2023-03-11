extends BackBufferCopy

@export var animation_delay : float = 1.0#s

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(animation_name : String = "subtle"):
	$Animation.set_speed_scale(1.0/animation_delay)
	if $Animation.has_animation(animation_name):
		$Animation.play(animation_name)
	else :
		printerr("Distortion doesn't have animation "+animation_name)
		$Animation.play("subtle")
	await $Animation.animation_finished
	queue_free()
