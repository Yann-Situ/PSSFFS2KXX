extends BackBufferCopy

@export var time_scale : float = 1.0#s
@export var size : Vector2 = Vector2(128,128) : set = set_size#s

func set_size(v : Vector2):
	size = v
	$Shader.texture.width = size.x
	$Shader.texture.height = size.y

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(animation_name : String = "subtle"):
	$Animation.set_speed_scale(time_scale)
	if $Animation.has_animation(animation_name):
		$Animation.play(animation_name)
	else :
		printerr("Distortion doesn't have animation "+animation_name)
		$Animation.play("subtle")
	await $Animation.animation_finished
	queue_free()
