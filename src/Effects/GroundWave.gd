extends BackBufferCopy

@export var time_scale : float = 1.0#s
@export var size_scale : Vector2 = Vector2(1,1) : set = set_size_scale#s

func set_size_scale(v : Vector2):
	size_scale = v
	$Shader.texture.width *= size_scale.x
	$Shader.texture.height *= size_scale.y
	$Shader.material.set_shader_parameter("texture_height", 32*size_scale.y)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func start(animation_name : String = "subtle"):
	$Animation.set_speed_scale(time_scale)
	if $Animation.has_animation(animation_name):
		$Animation.play(animation_name)
	else :
		printerr("GroundWave doesn't have animation "+animation_name)
		$Animation.play("subtle")
	await $Animation.animation_finished
	queue_free()
