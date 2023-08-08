#@tool
extends Node2D

@export var palette_scheme_sampler : PaletteSchemeSampler
@export var seed : int = 0 : set = set_seed
@export var size : Vector2 = Vector2(96.0,24.0)
@export var gradient_interpolation : Gradient.InterpolationMode = Gradient.GRADIENT_INTERPOLATE_LINEAR
var count = 0
var rng = RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_seed(v : int):
	seed = v
	rng.seed = v

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_T:
			generate_scheme(pos(count))
			count += 1

func generate_scheme(_position : Vector2 = Vector2.ZERO):
	var palette_scheme = palette_scheme_sampler.sample(rng)
	for i in range(palette_scheme.size()):
		var s = Sprite2D.new()
		var g1d = GradientTexture1D.new()
		g1d.width = size.x
		g1d.gradient = palette_scheme.get_gradient(i)
		g1d.gradient.set_interpolation_mode(gradient_interpolation)
		#print(g1d.gradient.get_point_count())
		s.texture = g1d
		s.scale.y = size.y
		s.position = _position + i * size.y * Vector2.DOWN
		add_child(s)

func pos(i : int) -> Vector2:
	var n = int(ProjectSettings.get_setting("display/window/size/viewport_width") / size.x)
	var k = palette_scheme_sampler.color_samplers.size()
	var v = Vector2(i%n, i/n)
	v = Vector2(v.x * size.x, v.y * (k+0.5)*size.y)
	v += Vector2(0.6 * size.x, 0.6*size.y)
	return v
